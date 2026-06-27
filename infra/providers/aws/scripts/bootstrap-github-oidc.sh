#!/usr/bin/env bash
# Bootstrap GitHub Actions -> AWS OIDC trust and deployment role.
#
# This script:
#   1) Ensures the GitHub OIDC provider exists in IAM
#   2) Creates or updates an IAM role trusted by GitHub Actions OIDC
#   3) Attaches IAM managed policies to that role
#   4) Prints the role ARN required for GitHub secret AWS_ROLE_ARN
#
# Usage:
#   bash infra/providers/aws/scripts/bootstrap-github-oidc.sh
#
# Optional environment variables:
#   AWS_REGION            Default: current AWS config region or us-east-2
#   GITHUB_OWNER          Required if auto-detection fails
#   GITHUB_REPO           Required if auto-detection fails
#   ROLE_NAME             Default: reviewlens-github-actions-deploy
#   MANAGED_POLICY_ARNS   Comma-separated list of policy ARNs
#                         Default: arn:aws:iam::aws:policy/AdministratorAccess

set -euo pipefail

DEFAULT_AWS_REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
DEFAULT_AWS_REGION="${DEFAULT_AWS_REGION:-us-east-2}"
ROLE_NAME="${ROLE_NAME:-reviewlens-github-actions-deploy}"
DEFAULT_POLICIES="arn:aws:iam::aws:policy/AdministratorAccess"
MANAGED_POLICY_ARNS="${MANAGED_POLICY_ARNS:-$DEFAULT_POLICIES}"
OIDC_URL="https://token.actions.githubusercontent.com"
OIDC_HOST="token.actions.githubusercontent.com"
OIDC_THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"

# Try to infer owner/repo from git remote, then allow explicit env/prompt override.
DEFAULT_REPO_SLUG="$(git config --get remote.origin.url 2>/dev/null | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##' || true)"
DEFAULT_GITHUB_OWNER="${GITHUB_OWNER:-${DEFAULT_REPO_SLUG%%/*}}"
DEFAULT_GITHUB_REPO="${GITHUB_REPO:-${DEFAULT_REPO_SLUG##*/}}"

if [[ -z "${DEFAULT_GITHUB_OWNER}" || -z "${DEFAULT_GITHUB_REPO}" || "${DEFAULT_GITHUB_OWNER}" == "${DEFAULT_REPO_SLUG}" ]]; then
  DEFAULT_GITHUB_OWNER="${GITHUB_OWNER:-}"
  DEFAULT_GITHUB_REPO="${GITHUB_REPO:-}"
fi

echo "=== ReviewLens AI GitHub OIDC Bootstrap ==="
echo ""

read -r -p "AWS Region [${DEFAULT_AWS_REGION}]: " AWS_REGION_INPUT
AWS_REGION="${AWS_REGION_INPUT:-$DEFAULT_AWS_REGION}"

read -r -p "GitHub owner [${DEFAULT_GITHUB_OWNER:-required}]: " GITHUB_OWNER_INPUT
GITHUB_OWNER="${GITHUB_OWNER_INPUT:-${DEFAULT_GITHUB_OWNER:-}}"

read -r -p "GitHub repo [${DEFAULT_GITHUB_REPO:-required}]: " GITHUB_REPO_INPUT
GITHUB_REPO="${GITHUB_REPO_INPUT:-${DEFAULT_GITHUB_REPO:-}}"

read -r -p "IAM role name [${ROLE_NAME}]: " ROLE_NAME_INPUT
ROLE_NAME="${ROLE_NAME_INPUT:-$ROLE_NAME}"

if [[ -z "$GITHUB_OWNER" || -z "$GITHUB_REPO" ]]; then
  echo "Error: GitHub owner and repo are required." >&2
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
if [[ -z "$ACCOUNT_ID" || "$ACCOUNT_ID" == "None" ]]; then
  echo "Error: Could not resolve AWS account ID from current credentials." >&2
  exit 1
fi

echo ""
echo "Using account: ${ACCOUNT_ID}"
echo "Using region:  ${AWS_REGION}"
echo "GitHub repo:   ${GITHUB_OWNER}/${GITHUB_REPO}"
echo "Role name:     ${ROLE_NAME}"
echo ""

echo "Ensuring IAM OIDC provider exists: ${OIDC_URL}"
OIDC_PROVIDER_ARN="$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(Arn, '${OIDC_HOST}')].Arn | [0]" --output text)"

if [[ -z "$OIDC_PROVIDER_ARN" || "$OIDC_PROVIDER_ARN" == "None" ]]; then
  OIDC_PROVIDER_ARN="$(aws iam create-open-id-connect-provider \
    --url "$OIDC_URL" \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list "$OIDC_THUMBPRINT" \
    --query 'OpenIDConnectProviderArn' \
    --output text)"
  echo "Created OIDC provider: ${OIDC_PROVIDER_ARN}"
else
  echo "OIDC provider already exists: ${OIDC_PROVIDER_ARN}"
fi

tmp_trust_file="$(mktemp)"
cat > "$tmp_trust_file" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${OIDC_PROVIDER_ARN}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_OWNER}/${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF

echo "Ensuring IAM role exists: ${ROLE_NAME}"
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam update-assume-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-document "file://${tmp_trust_file}" >/dev/null
  echo "Updated trust policy on existing role: ${ROLE_NAME}"
else
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "file://${tmp_trust_file}" \
    --description "GitHub Actions OIDC role for ${GITHUB_OWNER}/${GITHUB_REPO}" >/dev/null
  echo "Created IAM role: ${ROLE_NAME}"
fi

IFS=',' read -r -a policy_arns <<< "$MANAGED_POLICY_ARNS"
for policy_arn in "${policy_arns[@]}"; do
  trimmed="$(echo "$policy_arn" | xargs)"
  if [[ -z "$trimmed" ]]; then
    continue
  fi

  if aws iam list-attached-role-policies \
    --role-name "$ROLE_NAME" \
    --query "AttachedPolicies[?PolicyArn=='${trimmed}'].PolicyArn | [0]" \
    --output text | grep -q "$trimmed"; then
    echo "Policy already attached: ${trimmed}"
  else
    aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$trimmed"
    echo "Attached policy: ${trimmed}"
  fi
done

ROLE_ARN="$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)"
rm -f "$tmp_trust_file"

echo ""
echo "=== GitHub OIDC Bootstrap Complete ==="
echo ""
echo "Set this repository secret in GitHub:"
echo "  Name:  AWS_ROLE_ARN"
echo "  Value: ${ROLE_ARN}"
echo ""
echo "GitHub CLI shortcut:"
echo "  gh secret set AWS_ROLE_ARN --body \"${ROLE_ARN}\""
echo ""
echo "Role ARN: ${ROLE_ARN}"

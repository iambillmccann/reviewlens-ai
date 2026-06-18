#!/bin/bash
# Bootstrap AWS state backend and create Secrets Manager secrets
# Must be run once before `terraform init`
#
# Usage:
#   bash bootstrap-state.sh
#
# Prompts for:
#   - AWS_REGION (default: us-east-1)
#   - AWS_ACCOUNT_ID (auto-detected if AWS CLI configured)

set -e

echo "=== ReviewLens AI AWS Bootstrap ==="
echo ""
echo "This script creates:"
echo "  - S3 bucket for Terraform state"
echo "  - DynamoDB table for state locking"
echo "  - AWS Secrets Manager secrets"
echo ""

# Get AWS region (prefer existing environment value)
DEFAULT_AWS_REGION="${AWS_REGION:-us-east-1}"
read -p "AWS Region [${DEFAULT_AWS_REGION}]: " AWS_REGION_INPUT
AWS_REGION="${AWS_REGION_INPUT:-$DEFAULT_AWS_REGION}"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)
if [ -z "$ACCOUNT_ID" ]; then
  read -p "AWS Account ID: " ACCOUNT_ID
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "Error: AWS Account ID required"
  exit 1
fi

echo "Using Account: $ACCOUNT_ID, Region: $AWS_REGION"
echo ""

# State bucket name
STATE_BUCKET="reviewlens-tf-state-${ACCOUNT_ID}"
LOCK_TABLE="reviewlens-tf-lock"

echo "Creating S3 bucket: $STATE_BUCKET"
if aws s3api head-bucket --bucket "$STATE_BUCKET" >/dev/null 2>&1; then
  echo "  (bucket already exists)"
else
  if [ "$AWS_REGION" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "$STATE_BUCKET" \
      --region "$AWS_REGION"
  else
    aws s3api create-bucket \
      --bucket "$STATE_BUCKET" \
      --region "$AWS_REGION" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
fi

echo "Enabling bucket versioning"
aws s3api put-bucket-versioning \
  --bucket "$STATE_BUCKET" \
  --region "$AWS_REGION" \
  --versioning-configuration Status=Enabled

echo "Enabling bucket encryption"
aws s3api put-bucket-encryption \
  --bucket "$STATE_BUCKET" \
  --region "$AWS_REGION" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo ""
echo "Creating DynamoDB lock table: $LOCK_TABLE"
aws dynamodb create-table \
  --table-name "$LOCK_TABLE" \
  --region "$AWS_REGION" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  2>/dev/null || echo "  (table may already exist)"

echo ""
echo "Creating Secrets Manager secrets"

# DATABASE_URL secret (placeholder for now)
DB_PASSWORD=$(openssl rand -base64 32)
DATABASE_URL="postgresql+psycopg://postgres:${DB_PASSWORD}@reviewlens-dev-db.c123456.us-east-1.rds.amazonaws.com:5432/reviewlens"

if ! aws secretsmanager create-secret \
  --name "reviewlens-database-url" \
  --region "$AWS_REGION" \
  --secret-string "$DATABASE_URL" \
  2>/dev/null; then
  aws secretsmanager update-secret \
    --secret-id "reviewlens-database-url" \
    --region "$AWS_REGION" \
    --secret-string "$DATABASE_URL"
fi

echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Next Steps:"
echo ""
echo "1. Create terraform.tfvars in infra/providers/aws/terraform/environments/dev/"
echo "   Copy from terraform.tfvars.example and fill in your values"
echo ""
echo "2. Get secret ARNs (paste into terraform.tfvars):"

DATABASE_URL_ARN=$(aws secretsmanager describe-secret \
  --secret-id "reviewlens-database-url" \
  --region "$AWS_REGION" \
  --query 'ARN' \
  --output text)

echo ""
echo "DATABASE_URL_ARN: $DATABASE_URL_ARN"
echo ""
echo "3. Update terraform.tfvars with the above ARN"
echo ""
echo "4. Initialize Terraform:"
echo "   cd infra/providers/aws/terraform/environments/dev"
echo "   terraform init -backend-config=\"bucket=$STATE_BUCKET\" -backend-config=\"key=dev/terraform.tfstate\""
echo ""
echo "5. Review and apply:"
echo "   terraform plan"
echo "   terraform apply"
echo ""

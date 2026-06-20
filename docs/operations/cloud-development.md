# Cloud Development Operations

This runbook covers first-time setup and daily operations for the cloud `dev` environment on AWS.

## First-Time Setup

1. Configure AWS OIDC trust between GitHub Actions and AWS.
2. Bootstrap Terraform remote state infrastructure (S3 bucket + DynamoDB lock table).
3. Ensure required repository secret exists:
   - `AWS_ROLE_ARN`
4. Prepare workflow-dispatch values for:
   - `aws_region`
   - `tf_state_bucket`
   - `tf_state_key`
   - `environment_name`
   - app config values required by `provision-dev.yml`

## Provision Workflow

Use `.github/workflows/provision-dev.yml` to create/update infrastructure.

Expected outcomes:

- Terraform apply succeeds
- Infrastructure outputs are available (App Runner URL, CloudFront domain, ECR repo, etc.)
- SSM/Secrets references are wired for deploy-time usage

## Deploy Workflow

Use `.github/workflows/deploy-dev.yml` after provision.

Deploy behavior:

- Resolves Terraform outputs
- Uses backend image tag `sha-<GITHUB_SHA>` (also updates `latest`)
- Reuses existing SHA-tagged image unless `force_backend_rebuild=true`
- Triggers App Runner deployment
- Builds and publishes frontend to S3 + CloudFront invalidation
- Runs smoke checks for:
  - frontend HTTP 200
  - `/api/v1/health`
  - `/api/v1/ready`
  - `/api/v1/version`
  - CORS header presence for frontend origin

## Teardown Workflow

Use `.github/workflows/teardown-dev.yml`.

Modes:

- `pause`: pause App Runner, stop RDS if available, clear frontend bucket content, invalidate CloudFront
- `destroy`: Terraform destroy of environment-managed resources

Optional behavior in destroy mode:

- `keep_ecr_repository=true` detaches ECR resources from Terraform state before destroy so image history can be retained

## Configuration Update Procedure

When environment values change, update configuration through the same path used by provisioning inputs and re-run provision/deploy as needed.

Typical sequence:

1. Update workflow input values used by `provision-dev.yml`.
2. Run `provision-dev.yml` to persist config updates.
3. Run `deploy-dev.yml` to roll app artifacts with updated runtime/build config.
4. Re-run smoke checks via deploy workflow result.

## Known Constraints

- GitHub-hosted runners cannot directly reach private RDS for migration execution.
- Database migrations are currently not performed from `deploy-dev.yml`.

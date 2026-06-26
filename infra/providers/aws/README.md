# AWS Infrastructure Adapter

Deploy Reviewlens-ai to AWS using Terraform and GitHub Actions.

## Architecture

- Frontend: AWS S3 + CloudFront
- Backend: AWS App Runner
- Database: Amazon RDS PostgreSQL 16
- Secrets/config: AWS Secrets Manager + Systems Manager Parameter Store
- State: S3 bucket + DynamoDB lock table
- Networking: VPC with public/private subnets and private RDS access from backend

## Prerequisites

1. AWS account with sufficient permissions
2. AWS CLI installed and configured
3. Terraform >= 1.7 installed locally
4. GitHub repository secret configured:
   - `AWS_ROLE_TO_ASSUME`

## Getting Started

### 1) Bootstrap Terraform Remote State

```bash
cd infra/providers/aws/scripts
bash bootstrap-state.sh
```

The bootstrap script creates remote-state resources and required bootstrap secrets for environment provisioning.

### 2) Configure Terraform Variables

Create `infra/providers/aws/terraform/environments/dev/terraform.tfvars`:

```hcl
aws_region = "us-east-1"

# Environment secrets/config
rds_database_url_arn = "arn:aws:secretsmanager:..."

# Container image
ecr_image_tag = "latest"

# Optional
cors_origins = "https://{cloudfront-domain}.cloudfront.net"
```

Keep this file local and out of source control.

### 3) Provision AWS Resources

```bash
cd infra/providers/aws/terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### 4) Deploy Application Artifacts

Use GitHub Actions workflows:

- `.github/workflows/provision-dev.yml`
- `.github/workflows/deploy-dev.yml`
- `.github/workflows/teardown-dev.yml`

## Repo-Local Shell Variables

Use project-scoped shell variables:

```bash
source scripts/aws-env.sh
```

This keeps AWS and GitHub-related values scoped to this repository.

## Cost Management

Pause between sessions when possible:

```bash
cd infra/providers/aws/terraform/environments/dev
aws apprunner pause-service --service-arn <app-runner-arn>
aws rds stop-db-instance --db-instance-identifier reviewlens-ai-dev
aws s3 rm s3://<bucket-name> --recursive
```

Destroy when environment reset is needed:

```bash
cd infra/providers/aws/terraform/environments/dev
terraform destroy
```

## Source Control Hygiene

Commit Terraform source files, scripts, and documentation.

Do not commit:

- `.terraform/`
- `*.tfstate*`
- `.terraform.lock.hcl`
- `*.tfplan*`
- `crash*.log`

## Troubleshooting

### RDS connection timeout

- Verify App Runner VPC connector is attached
- Verify security groups allow backend to reach RDS
- Verify the database URL secret value

### App Runner deployment fails

- Verify image exists in ECR
- Verify execution role can read required secrets
- Check App Runner service logs

### CloudFront serves 404s for routes

- Verify SPA fallback to `/index.html`
- Verify CloudFront can read from S3 origin

## References

- Terraform modules: `infra/providers/aws/terraform/modules/`
- Environment config: `infra/providers/aws/terraform/environments/dev/`
- Bootstrap script: `infra/providers/aws/scripts/bootstrap-state.sh`
- Workflows: `.github/workflows/provision-dev.yml`, `.github/workflows/deploy-dev.yml`, `.github/workflows/teardown-dev.yml`

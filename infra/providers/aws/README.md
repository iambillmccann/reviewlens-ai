# AWS Infrastructure Adapter

Deploy Cornerstone to AWS using Terraform and GitHub Actions.

## Architecture

- **Frontend:** AWS S3 + CloudFront (static site hosting with HTTPS and SPA routing)
- **Backend:** AWS App Runner (managed container service with stable URL, pause/resume)
- **Database:** Amazon RDS PostgreSQL 16 (t4g.micro instance)
- **Secrets:** AWS Secrets Manager + Systems Manager Parameter Store
- **State:** S3 bucket + DynamoDB lock table
- **Networking:** VPC with public + private subnets, NAT egress for backend, and private RDS access from backend only

## Prerequisites

1. **AWS Account** with admin access
2. **Clerk Application** already configured (from existing deployment)
3. **Clerk Keys:** `CLERK_JWKS_URL`, `CLERK_SECRET_KEY`, `CLERK_PUBLISHABLE_KEY`
4. **AWS CLI** installed and configured with credentials
5. **Terraform** (>= 1.7) installed locally
6. **GitHub Actions** secrets configured in the repository (see "GitHub Actions Setup" below)

## Getting Started

### Step 1: Bootstrap AWS State Backend (One-Time)

The state backend (S3 bucket + DynamoDB table) must exist before Terraform can initialize.

```bash
cd infra/providers/aws/scripts
bash bootstrap-state.sh

# This script:
# - Creates S3 bucket for Terraform state (cornerstone-tf-state-{account-id})
# - Enables versioning and encryption
# - Creates DynamoDB lock table
# - Creates AWS Secrets Manager secrets:
#   - cornerstone-database-url (RDS password TBD, placeholder for now)
#   - cornerstone-clerk-secret-key (from CLERK_SECRET_KEY env var)
# - Outputs secret ARNs for use in terraform.tfvars
```

The script prompts for `CLERK_SECRET_KEY`. Provide your actual Clerk secret key.

### Step 2: Configure Terraform Variables

Create `infra/providers/aws/terraform/environments/dev/terraform.tfvars`:

```hcl
aws_region = "us-east-1"

# Clerk
clerk_jwks_url          = "https://your-instance.clerk.accounts.com/.well-known/jwks.json"
# Optional for compatibility, but recommended for strict JWT validation:
clerk_issuer            = "https://your-instance.clerk.accounts.com"
clerk_audience          = "your-clerk-audience" # typically your app name
clerk_publishable_key   = "pk_test_..."         # from Clerk dashboard
clerk_secret_key_arn    = "arn:aws:secretsmanager:..."  # output from bootstrap-state.sh

# RDS (will be set by bootstrap script later)
rds_database_url_arn    = "arn:aws:secretsmanager:..."  # output from bootstrap-state.sh

# ECR
ecr_image_tag           = "latest"

# Optional
cors_origins            = "https://{cloudfront-domain}.cloudfront.net"  # set after first provision
```

**Save as `.gitignore`d file.** Never commit actual secrets.

### Step 3: Provision AWS Resources

```bash
cd infra/providers/aws/terraform/environments/dev

# Initialize Terraform (reads remote backend config from backend.tf)
terraform init

# Preview resources to be created
terraform plan

# Apply (creates all AWS resources)
terraform apply
```

**Outputs printed at the end:**

- CloudFront domain URL (e.g., `https://d12345.cloudfront.net`)
- App Runner service URL (e.g., `https://abc123.us-east-1.awsapprunner.com`)
- RDS endpoint (e.g., `postgresdb.c123456.us-east-1.rds.amazonaws.com`)

### Step 4: Update Clerk Dashboard

Log in to [Clerk Dashboard](https://dashboard.clerk.com):

1. Go to **Allowed Origins**
2. Add the CloudFront URL (from Terraform outputs): `https://d12345.cloudfront.net`
3. Go to **Redirect URLs**
4. Add:
   - Frontend signup/signin: `https://d12345.cloudfront.net/sign-in`
   - Backend callback: `https://d12345.cloudfront.net/sign-up`
5. Save

### Step 5: Configure GitHub Actions Secrets

In your GitHub repository settings, add the following secrets:

| Secret Name                  | Value                                             |
| ---------------------------- | ------------------------------------------------- |
| `AWS_ROLE_ARN`               | IAM OIDC role ARN (see "GitHub OIDC Setup" below) |
| `AWS_REGION`                 | e.g., `us-east-1`                                 |
| `ECR_REPOSITORY_URL`         | From Terraform output                             |
| `APP_RUNNER_SERVICE_ARN`     | From Terraform output                             |
| `S3_BUCKET_NAME`             | From Terraform output                             |
| `CLOUDFRONT_DISTRIBUTION_ID` | From Terraform output                             |
| `DATABASE_URL_SECRET_ARN`    | From bootstrap-state.sh output                    |

### Step 6: Deploy

Push to `main` branch. GitHub Actions workflows will:

1. Run CI checks (lint, typecheck, tests)
2. Build Docker image and push to ECR
3. Run Alembic migrations
4. Deploy to App Runner
5. Build and deploy frontend to S3 + invalidate CloudFront
6. Run smoke tests

## GitHub OIDC Setup (One-Time)

For GitHub Actions to authenticate to AWS without long-lived access keys:

### Option A: Automated (Recommended)

Use `terraform-aws-modules` OIDC provider module (documented in AWS module code).

### Option B: Manual AWS Console

1. Go to **IAM → Identity Providers**
2. Create new provider:
   - Provider type: OpenID Connect
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
3. Go to **IAM → Roles**
4. Create new role:
   - Trust entity: Web identity (select GitHub provider)
   - Permissions: Attach policies for ECR, App Runner, RDS, S3, CloudFront, Secrets Manager, SSM
   - Trust policy should allow GitHub Actions to assume the role
5. Copy the role ARN and add as `AWS_ROLE_ARN` secret in GitHub

See AWS documentation for detailed OIDC setup: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect

### Repo-Local Shell Variables

For Cornerstone-specific shell variables, source [scripts/aws-env.sh](../../../../scripts/aws-env.sh) from the repo root instead of editing `~/.bashrc`:

```bash
source scripts/aws-env.sh
```

This keeps `AWS_PROFILE`, `AWS_REGION`, `GITHUB_OWNER`, `GITHUB_REPO`, and `ROLE_NAME` scoped to this project.

## Cost Estimates

| Component                    | Monthly Cost |
| ---------------------------- | ------------ |
| App Runner (minimal traffic) | $5–20        |
| RDS t4g.micro (running)      | $11.50       |
| CloudFront                   | $0–1         |
| S3                           | ~$0.02       |
| Secrets Manager              | $0.80        |
| **Total (running)**          | **~$18–35**  |

### Pause Mode (Recommended Between Sessions)

```bash
cd infra/providers/aws/terraform/environments/dev
aws apprunner pause-service --service-arn <app-runner-arn>
aws rds stop-db-instance --db-instance-identifier cornerstone-dev
# Empty S3 bucket
aws s3 rm s3://<bucket-name> --recursive
```

**Cost when paused:** ~$3–5/month (RDS storage + Secrets Manager only)

### Full Destroy

```bash
cd infra/providers/aws/terraform/environments/dev
terraform destroy
```

**Warning:** CloudFront URL and App Runner URL will change on next `terraform apply`. Clerk dashboard must be updated.

## Source Control Hygiene (Terraform)

Commit Terraform source, not Terraform runtime artifacts.

Commit:

- `*.tf` module/environment definitions
- scripts and documentation
- sanitized examples (for example `terraform.tfvars.example`)

Do not commit:

- `.terraform/` directories (provider binaries and module cache)
- `*.tfstate*` files
- `.terraform.lock.hcl`, `*.tfplan*`
- `crash*.log`, `.terraformrc`, `terraform.rc`, `.terragrunt-cache/`

Keep environment-specific values and secrets in local `terraform.tfvars` files, never in git.

## Troubleshooting

### RDS connection timeout

- Check security group allows inbound from the App Runner VPC connector security group
- Verify App Runner VPC connector is attached and healthy
- Confirm DATABASE_URL in Secrets Manager is correct

### App Runner deployment fails

- Check Docker image in ECR is present
- Verify App Runner IAM execution role has Secrets Manager read permissions
- Check App Runner logs in AWS console

### CloudFront shows 404 for all routes

- Verify SPA fallback is configured (should redirect 404 to `/index.html`)
- Check S3 bucket policy allows CloudFront to read objects

### Clerk auth fails

- Verify `VITE_CLERK_PUBLISHABLE_KEY` is injected at build time
- Check Clerk allowed origins include CloudFront URL
- Verify CORS_ORIGINS SSM parameter includes frontend URL

## Reference

- Terraform modules: `infra/providers/aws/terraform/modules/`
- Dev environment config: `infra/providers/aws/terraform/environments/dev/`
- Bootstrap script: `infra/providers/aws/scripts/bootstrap-state.sh`
- GitHub Actions workflows: `.github/workflows/deploy-dev.yml`, `.github/workflows/teardown-dev.yml`, etc.

## Next Steps (Future)

- Add custom domain via Route53
- Implement staging/production environments with same adapter pattern
- Add GCP and Azure adapters

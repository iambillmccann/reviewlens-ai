# Reviewlens-ai

Reviewlens-ai is the working application repository.

It provides a React/Vite frontend, FastAPI backend, PostgreSQL persistence, and AWS deployment workflows.

---

**AWS OIDC Trust Setup:**

The AWS account, IAM OIDC provider, and GitHub ↔ AWS trust relationship are now established for secure, keyless deployment. See `docs/decisions/0004-iaas-refactor.md` and `docs/development-logs/9-iaas-refactor.txt` for the exact commands and process.

## Frontend UX + PWA Baseline

Recent template baseline updates include:

- Header account controls now use a user-avatar dropdown menu (Settings, Account, Sign out)
- Left sidebar now contains primary navigation only (Home)
- Mobile/tablet ergonomics improved with a larger avatar trigger touch target
- Progressive Web App (PWA) support is enabled for the web app

PWA implementation notes:

- Build plugin: vite-plugin-pwa
- Install assets: web manifest and app icons under apps/web/public/icons/
- Runtime caching is conservative for SaaS auth safety:
  - NetworkOnly for API traffic
  - StaleWhileRevalidate for static assets
  - NetworkFirst for non-API page navigations
- Service worker is registered in production builds

PWA validation (from apps/web):

```bash
nvm use 20.19.0
npm run lint
npm run typecheck
npm run build
npm run preview
```

Then verify installability and service worker behavior in browser DevTools Application tab (or Lighthouse PWA audit).

## Local Development

Run local development with three running processes:

- PostgreSQL (Docker)
- FastAPI backend (`apps/api`)
- Vite frontend (`apps/web`)

### Prerequisites

- Docker Desktop running
- Python 3.11+ installed
- Node 20.19.0 installed (`nvm use 20.19.0`)

### First-Time Setup

1. Start database (from repo root):

```bash
./scripts/dev-db-up.sh
```

2. Set up backend environment and install dependencies:

```bash
cd apps/api
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
pip install -e ".[dev]"
alembic upgrade head
```

3. Install frontend dependencies:

```bash
cd apps/web
nvm use 20.19.0
npm install
```

### Start Local Dev Environment

Open three terminals.

Terminal 1 (database, from repo root):

```bash
./scripts/dev-db-up.sh
```

Terminal 2 (backend API):

```bash
cd apps/api
source .venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

Terminal 3 (frontend):

```bash
cd apps/web
nvm use 20.19.0
npm run dev
```

App URLs:

- Frontend: `http://localhost:5173`
- Backend health: `http://127.0.0.1:8000/api/v1/health`

### Stop Local Dev Environment

1. Stop frontend and backend with `Ctrl+C` in their terminals.
2. Stop database from repo root:

```bash
./scripts/dev-db-down.sh
```

### Reset Local Database (Optional)

If you need a clean local DB:

```bash
./scripts/dev-db-reset.sh
cd apps/api
source .venv/bin/activate
alembic upgrade head
```

## Terraform Source Control Rules

If you work under `infra/`, commit Terraform source files and ignore Terraform runtime artifacts.

Commit these:

- `*.tf`, `*.tfvars.example`, module code, scripts, and docs
- Environment configuration templates that do not include secrets

Do not commit these:

- `.terraform/` (provider binaries and module cache)
- `*.tfstate*` (state files and backups)
- `.terraform.lock.hcl` and `*.tfplan*`
- `crash*.log`, `.terraformrc`, `terraform.rc`, `.terragrunt-cache/`

Use local `terraform.tfvars` files for environment values and secrets, and keep them out of git.

## Operator Scripts

| Script                                      | Purpose                                                                                                                |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `scripts/aws-env.sh`                        | Sets project-scoped `AWS_PROFILE`, `AWS_REGION`, and `GITHUB_REPO` variables for use in other scripts and CLI commands |
| `scripts/cloud-status.sh <aws\|azure\|gcp>` | Checks the running state of cloud resources without needing to know any URLs                                           |
| `scripts/dev-db-up.sh`                      | Start the local PostgreSQL container                                                                                   |
| `scripts/dev-db-down.sh`                    | Stop the local PostgreSQL container                                                                                    |
| `scripts/dev-db-reset.sh`                   | Wipe and recreate the local database                                                                                   |

`cloud-status.sh` is template-portable: it derives the resource name prefix from `GITHUB_REPO` in `aws-env.sh`, so apps built from Reviewlens-ai only need to update that one variable.

## AWS Manual Setup Notes

When running AWS manual setup for this repository, use project-scoped shell variables instead of global shell configuration:

```bash
source scripts/aws-env.sh
```

This prevents AWS profile/region leakage into unrelated projects.

Before provisioning, validate account and region explicitly:

```bash
aws sts get-caller-identity
aws configure get region
```

If AWS Toolkit in VS Code shows multiple regions in Explorer, treat that as UI state. Use explicit CLI profile/region resolution as the source of truth for deployment commands.

## GitHub Actions AWS Setup

Current GitHub Actions coverage includes:

- `ci.yml`: web, API, and Terraform fmt/validate checks
- `provision-dev.yml`: manual Terraform apply for the AWS dev environment
- `deploy-dev.yml`: manual backend/frontend deployment to the provisioned AWS dev environment
- `teardown-dev.yml`: manual teardown with `pause` or `destroy` mode

Workflow editor note:

- The workflow files include an explicit YAML schema hint for GitHub Actions to reduce false-positive parser errors in the VS Code Problems panel.

Repository secret required:

- `AWS_ROLE_TO_ASSUME`: IAM role trusted by GitHub OIDC

Provision workflow inputs:

- `AWS_REGION`: AWS deployment region, for example `us-east-2`
- `TF_STATE_BUCKET`: remote Terraform state bucket name created by bootstrap
- `TF_STATE_KEY`: remote Terraform state object key, for example `dev/terraform.tfstate`
- `ENVIRONMENT_NAME`: Terraform environment name, typically `dev`
- `RDS_DATABASE_URL_ARN`: Secrets Manager ARN for the database URL
- `CORS_ORIGINS`: CloudFront URL after first provision; may be blank on the first run

Provision workflow behavior notes:

- Performs a targeted early bootstrap of database/networking and ECR before full plan/apply.
- Synchronizes `RDS_DATABASE_URL_ARN` secret value from the live RDS-managed credentials and endpoint.
- Uses a psycopg-compatible connection URL with `sslmode=require` for App Runner connectivity to private RDS.
- Pushes a minimal placeholder image to ECR so first-time App Runner service creation can pull `latest`.

Deploy workflow inputs:

- `AWS_REGION`
- `TF_STATE_BUCKET`
- `TF_STATE_KEY`
- `ENVIRONMENT_NAME`
- `FORCE_BACKEND_REBUILD`: `true` or `false`

Deploy workflow behavior notes:

- Ensures `/reviewlens-ai-dev/cors_origins` contains the current CloudFront origin before App Runner deployment.
- Treats App Runner `ROLLBACK_SUCCEEDED` as a terminal deployment failure state (fail-fast instead of timing out).

Teardown workflow inputs:

- `MODE`: `pause` or `destroy`
- `AWS_REGION`
- `TF_STATE_BUCKET`
- `TF_STATE_KEY`
- `ENVIRONMENT_NAME`
- `CONFIRM_DESTROY`: must be set to `DESTROY` for destroy mode
- `KEEP_ECR_REPOSITORY`: `true` or `false` (destroy mode only)

Backend image behavior in deploy workflow:

- Uses immutable backend image tag format `sha-<GITHUB_SHA>` and also updates `latest`
- Checks ECR for `sha-<GITHUB_SHA>` before build
- Reuses existing SHA-tagged image when present (unless `FORCE_BACKEND_REBUILD=true`)
- Builds and pushes new image when SHA tag is missing

Important constraint:

- GitHub-hosted runners cannot directly reach the current private RDS instance, so database migrations are not part of `deploy-dev.yml` yet.

Teardown behavior summary:

- `pause` mode: pauses App Runner, stops RDS (if available), empties frontend S3 content, and invalidates CloudFront
- `destroy` mode: runs `terraform destroy` for the dev environment state
- `destroy` + `KEEP_ECR_REPOSITORY=true`: detaches ECR resources from Terraform state before destroy, so the repository remains in AWS

ECR preserve caveat:

- If ECR is preserved during destroy, a later Terraform apply may require importing the existing ECR resources back into state.

## AWS Resource Organization

This repository does not use a CloudFormation stack or AWS CDK stack to group resources.

Instead, AWS resources are organized by:

- Terraform state in `infra/providers/aws/terraform/environments/dev`
- Consistent naming with the `reviewlens-ai-dev-*` prefix
- Shared AWS tags such as `Project=reviewlens-ai`, `Environment=dev`, and `ManagedBy=terraform`

That means full teardown will be driven by `terraform destroy`, not by deleting a single AWS stack.

Two exceptions are outside normal Terraform teardown because they are bootstrap-managed:

- Terraform remote state bucket + DynamoDB lock table
- Secrets Manager bootstrap secrets

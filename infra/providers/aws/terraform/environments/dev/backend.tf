terraform {
  backend "s3" {
    # These values must be provided via backend config during init or via -backend-config flags
    # Example: terraform init -backend-config="key=dev/terraform.tfstate" -backend-config="bucket=cornerstone-tf-state-123456789"
    encrypt        = true
    dynamodb_table = "cornerstone-tf-lock"
  }
}

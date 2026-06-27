terraform {
  backend "s3" {
    # These values must be provided via backend config during init or via -backend-config flags.
    # Example:
    # terraform init \
    #   -backend-config="bucket=reviewlens-tf-state-123456789012" \
    #   -backend-config="key=dev/terraform.tfstate" \
    #   -backend-config="region=us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}

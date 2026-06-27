aws_region = "us-east-2"
environment_name = "dev"

# These ARNs are output by bootstrap-state.sh
rds_database_url_arn = "arn:aws:secretsmanager:us-east-2:798128976501:secret:reviewlens-database-url-Sniv9U"

# RDS Configuration
rds_instance_class       = "db.t4g.micro"
rds_storage_gb           = 20
rds_public_accessibility = false

# CORS (set after first provision when CloudFront domain is known)
cors_origins = "https://d32c4rkhhvc6sn.cloudfront.net"

# Docker
ecr_image_tag = "latest"

# App Runner
app_runner_cpu    = 256
app_runner_memory = 512

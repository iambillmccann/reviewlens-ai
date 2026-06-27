variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "cors_origins" {
  type = string
}

variable "vite_api_base_url" {
  type = string
}

output "ssm_cors_origins" {
  value = aws_ssm_parameter.cors_origins.name
}

output "ssm_cors_origins_arn" {
  value = aws_ssm_parameter.cors_origins.arn
}

output "ssm_cors_origins_name" {
  value = aws_ssm_parameter.cors_origins.name
}

output "ssm_vite_api_base_url" {
  value = aws_ssm_parameter.vite_api_base_url.name
}

# SSM Parameters for configuration
resource "aws_ssm_parameter" "cors_origins" {
  name      = "/${var.name_prefix}/cors_origins"
  type      = "String"
  value     = var.cors_origins != "" ? var.cors_origins : "http://localhost:5173"
  overwrite = true

  tags = {
    Name = "${var.name_prefix}-cors-origins"
  }
}

resource "aws_ssm_parameter" "vite_api_base_url" {
  name      = "/${var.name_prefix}/vite_api_base_url"
  type      = "String"
  value     = var.vite_api_base_url
  overwrite = true

  tags = {
    Name = "${var.name_prefix}-vite-api-base-url"
  }
}

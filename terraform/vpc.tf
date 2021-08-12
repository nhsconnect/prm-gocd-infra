resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "GoCD ${var.environment} vpc"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "vpc_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-vpc-id"
  type  = "String"
  value = aws_vpc.main.id

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "cidr_block" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-cidr-block"
  type  = "String"
  value = var.vpc_cidr_block

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_flow_log" "nhs_audit" {
  log_destination      = data.aws_ssm_parameter.nhs_audit_flow_s3_bucket_arn.value
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

data "aws_ssm_parameter" "nhs_audit_flow_s3_bucket_arn" {
  name = "/repo/user-input/external/nhs-audit-vpc-flow-log-s3-bucket-arn"
}

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
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-vpc-id"
  type  = "String"
  value = aws_vpc.main.id

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "cidr_block" {
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-cidr-block"
  type  = "String"
  value = var.vpc_cidr_block

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

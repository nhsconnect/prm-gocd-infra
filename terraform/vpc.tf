resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "GoCD ${var.environment} vpc"
  }
}

resource "aws_ssm_parameter" "vpc_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-${var.environment}/vpc_id"
  type  = "String"
  value = aws_vpc.main.id
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

data "aws_ssm_parameter" "public_zone_id" {
    name = "/repo/output/prm-deductions-base-infra/root-zone-id"
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "gocd_db_username" {
  name = "/repo/${var.environment}/user-input/gocd-db-username"
}

data "aws_ssm_parameter" "gocd_db_password" {
  name = "/repo/${var.environment}/user-input/gocd-db-password"
}
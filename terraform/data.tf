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

data "aws_ssm_parameter" "inbound_ips" {
    name = "/NHS/dev-${data.aws_caller_identity.current.account_id}/tf/inbound_ips"
}

data "aws_ssm_parameter" "public_zone_id" {
    name = "/repo/prm-deductions-base-infra/output/root-zone-id"
}

data "aws_caller_identity" "current" {}

# data "aws_ssm_parameter" "dynamic_gocd_sg" {
#   name = "/repo/${var.environment}/prm-deductions-base-infra/output/gocd-sg"
# }

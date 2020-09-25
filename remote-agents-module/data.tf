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

# These values are part of GoCD deployment. Here, we just read them when deploying remote agents

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "root_domain" {
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-root-domain"
}

data "aws_ssm_parameter" "agent_image_tag" {
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-agent-image-tag"
}

data "aws_ssm_parameter" "agent_instance_profile" {
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-agent-instance-profile"
}

data "aws_ssm_parameter" "agent_keypair_name" {
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-agent-keypair-name"
}

data "aws_ssm_parameter" "agent_sg_id" {
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-agent-sg-id"
}

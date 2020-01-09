
module "local-agents" {
    source = "./agent-module"
    root_domain = var.root_domain
    agent_count = 4
    subnet_id = local.subnet_id
    region = var.region
    agent_image_tag = var.agent_image_tag
    environment = var.environment
    allocate_public_ip = true #TODO: use NAT for agents
    gocd_agent_volume_size = var.gocd_agent_volume_size
    agent_flavor = var.agent_flavor
    az = var.az
    agent_sg_id = aws_security_group.go_agent_sg.id
    agent_instance_profile = aws_iam_instance_profile.gocd_agent.name
    agent_keypair_name = aws_key_pair.gocd.key_name
    agent_resources = "docker"
}

resource "aws_ssm_parameter" "root_domain" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-${var.environment}/root_domain"
  type  = "String"
  value = var.root_domain
}

resource "aws_ssm_parameter" "agent_image_tag" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-${var.environment}/agent_image_tag"
  type  = "String"
  value = var.agent_image_tag
}

resource "aws_ssm_parameter" "agent_instance_profile" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-${var.environment}/agent_instance_profile"
  type  = "String"
  value = aws_iam_instance_profile.gocd_agent.name
}

resource "aws_ssm_parameter" "agent_keypair_name" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-${var.environment}/agent_keypair_name"
  type  = "String"
  value = aws_key_pair.gocd.key_name
}

resource "aws_ssm_parameter" "agent_sg_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-${var.environment}/agent_sg_id"
  type  = "String"
  value = aws_security_group.go_agent_sg.id
}

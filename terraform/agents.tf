
module "local-agents" {
    source = "./agent-module"
    root_domain = var.root_domain
    agent_count = 3
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
<<<<<<< HEAD
  name = "/repo/${var.environment}/${var.repo_name}/output/gocd-root-domain"
=======
  name = "/repo/${var.environment}/output/prm-gocd-infra/gocd-root-domain"
>>>>>>> [PRMT-1121] Move output to match the ssm keys convention
  type  = "String"
  value = var.root_domain

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "agent_image_tag" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-agent-image-tag"
  type  = "String"
  value = var.agent_image_tag

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "agent_instance_profile" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-agent-instance-profile"
  type  = "String"
  value = aws_iam_instance_profile.gocd_agent.name

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "agent_keypair_name" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-agent-keypair-name"
  type  = "String"
  value = aws_key_pair.gocd.key_name

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "agent_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-agent-sg-id"
  type  = "String"
  value = aws_security_group.go_agent_sg.id

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

locals {
  root_domain = data.aws_ssm_parameter.root_domain.value
  agent_image_tag = data.aws_ssm_parameter.agent_image_tag.value
  agent_instance_profile = data.aws_ssm_parameter.agent_instance_profile.value
  agent_keypair_name = data.aws_ssm_parameter.agent_keypair_name.value
  agent_sg_id = aws_security_group.go_agent_sg.id
  agent_resources = var.agent_resources
}

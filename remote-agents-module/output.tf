output "root_domain" {
  value = data.aws_ssm_parameter.root_domain.value
}

output "agent_sg_id" {
  value = data.aws_ssm_parameter.agent_sg_id.value
}

output "remote_agent_sg_id" {
  value = aws_security_group.go_agent_sg.id
}
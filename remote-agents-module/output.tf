output "root_domain" {
  value = data.aws_ssm_parameter.root_domain.value
}

output "agent_sg_id" {
  value = data.aws_ssm_parameter.agent_sg_id.value
}

output "agent_ips" {
  value = aws_instance.gocd_agent.*.public_ip
}

output "agent_repo_services_sg_id" {
  value = var.agent_repo_services_sg_id
}
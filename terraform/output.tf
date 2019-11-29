
output "agent_ips" {
  value = aws_instance.gocd_agent.*.public_ip
}

output "server_public_ip" {
  value = aws_instance.gocd_server.public_ip
}

output "environment" {
  value = var.environment
}

output "remote_user" {
  value = local.remote_user
}

output "agent_ips" {
  value = aws_instance.gocd_agent.*.public_ip
}
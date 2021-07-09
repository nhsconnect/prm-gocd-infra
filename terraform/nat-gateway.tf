resource "aws_nat_gateway" "gocd_agent" {
  allocation_id = aws_eip.gocd_agent_nat.id
  subnet_id = aws_subnet.public-subnet.id
}

resource "aws_eip" "gocd_agent_nat" {
}

resource "aws_ssm_parameter" "gocd_agent_nat_eip" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-agent-public-ip"
  type  = "String"
  value = aws_eip.gocd_agent_nat.public_ip
}

resource "aws_security_group" "gocd_server" {
  name        = "gocd-${var.environment}"
  description = "GoCD server ${var.environment}"
  vpc_id      = aws_vpc.main.id

  # Allow connections to GoCD from local networks
  ingress {
    from_port   = 8153
    to_port     = 8154
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "${var.my_ip}/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(split(",", "${data.aws_ssm_parameter.inbound_ips.value}"),
      ["10.0.0.0/8", "${var.my_ip}/32"])
  }

  # SSH for provisioning from whitelisted IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(split(",", "${data.aws_ssm_parameter.inbound_ips.value}"),
      ["10.0.0.0/8", "${var.my_ip}/32"])
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Security group for GoCD server VM"
    CreatedBy   = "prm-gocd-infra"
    Environment = var.environment
  }
}

# Agent Instance Security group
resource "aws_security_group" "go_agent_sg" {
  name        = "GoCD agent VM security group - ${var.environment}"
  description = "Security group for GoCD agent VM in ${var.environment} environment"
  vpc_id      = aws_vpc.main.id

  # ssh traffic from whitelisted IPs and local subnets
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(split(",", "${data.aws_ssm_parameter.inbound_ips.value}"),
      ["10.0.0.0/8", "${var.my_ip}/32"])
  }

  egress {
    # allow all outgoing traffic
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Security group for GoCD agent VM"
    CreatedBy   = "prm-gocd-infra"
    Environment = var.environment
  }
}

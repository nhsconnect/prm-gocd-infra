variable "users" {
  default = []
}

data "aws_ssm_parameter" "ip" {
  count = length(var.users)
  name  = "/repo/prm-deductions-base-infra/user-input/whitelisted-ipv4-${var.users[count.index]}"
}

locals {
  agent_cidrs = [
    for ip in module.local-agents.agent_ips :
    "${ip}/32"
  ]
  whitelist_ips = [
    for ip in data.aws_ssm_parameter.ip.*.value :
    "${ip}/32"
  ]
  # This local should be the only source of truth on what IPs are allowed to connect from the Internet
  allowed_public_ips = concat(local.whitelist_ips, local.agent_cidrs)
}

resource "aws_security_group" "gocd_sg" {
  name        = "GoCD public access"
  description = "Security group for GoCD public access"
  vpc_id      = aws_vpc.main.id

  # HTTPS from whitelisted IP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.allowed_public_ips
  }

  tags = {
    Name = "GoCD public access"
  }
}

resource "aws_security_group" "gocd_server" {
  name        = "gocd-${var.environment}"
  description = "GoCD server ${var.environment}"
  vpc_id      = aws_vpc.main.id

  # Allow connections to GoCD from local networks
  ingress {
    from_port   = 8153
    to_port     = 8154
    protocol    = "tcp"
    cidr_blocks = concat(["10.0.0.0/8", "${var.my_ip}/32"])
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(["10.0.0.0/8", "${var.my_ip}/32"])
  }

  # SSH for provisioning from whitelisted IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(["10.0.0.0/8", "${var.my_ip}/32"])
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    cidr_blocks = ["10.0.0.0/8", "${var.my_ip}/32"]
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

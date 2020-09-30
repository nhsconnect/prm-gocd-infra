
# Agent Instance Security group
resource "aws_security_group" "go_agent_sg" {
  name        = "GoCD agent VM security group - ${var.environment}"
  description = "Security group for GoCD agent VM in ${var.environment} environment"
  vpc_id      = var.vpc_id

  # ssh traffic from whitelisted IPs and local subnets
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "86.53.244.42/32"]
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
    CreatedBy = var.repo_name
    Environment = var.environment
  }
}

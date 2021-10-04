resource "aws_cloudwatch_log_group" "gocd_vpn" {
  name = "${var.environment}-gocd-vpn-client-logs"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_stream" "gocd_vpn" {
  name           = "main"
  log_group_name = aws_cloudwatch_log_group.gocd_vpn.name
}

data "aws_acm_certificate" "gocd_vpn" {
  domain   = "${var.environment}.gocd.vpn.patient-deductions.nhs.uk"
}

resource "aws_ec2_client_vpn_endpoint" "gocd_vpn" {
  server_certificate_arn = data.aws_acm_certificate.gocd_vpn.arn
  client_cidr_block      = var.vpn_client_subnet
  split_tunnel           = true
  dns_servers            = [cidrhost(aws_vpc.main.cidr_block, 2)]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.gocd_vpn.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.gocd_vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.gocd_vpn.name
  }

  tags = {
    Name = "${var.environment}-gocd-vpn"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "gocd_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.gocd_vpn.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}

resource "aws_ssm_parameter" "client_vpn_endpoint_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/client-vpn-endpoint-id"
  type = "String"
  value = aws_ec2_client_vpn_endpoint.gocd_vpn.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ec2_client_vpn_network_association" "private_subnet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.gocd_vpn.id
  subnet_id              = aws_subnet.private.id
  security_groups        = [ aws_security_group.gocd_vpn.id ]
}

resource "aws_security_group" "gocd_vpn" {
  name        = "${var.environment}-vpn-sg"
  description = "Client VPN in GoCD${var.environment} env"
  vpc_id      = aws_vpc.main.id

  //TODO: make less open
  egress {
    description = "Allow All Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-gocd-vpn-sg"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

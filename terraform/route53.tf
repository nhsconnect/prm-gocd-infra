# Private zone
resource "aws_route53_zone" "private" {
  name = "${var.environment}.gocd.${var.root_domain}"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name      = "Private DNS zone for ${var.environment} GoCD"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }

  lifecycle {
    # Because other deductions VPCs are associated in other repos
    ignore_changes = [
      vpc
    ]
  }
}

resource "aws_ssm_parameter" "gocd_zone_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-route53-zone-id"
  type = "String"
  value = aws_route53_zone.private.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_route53_record" "gocd_private" {
  zone_id = aws_route53_zone.private.id
  name    = "${var.environment}.gocd.${var.root_domain}"
  type    = "A"
  ttl     = "3600"
  records = [aws_instance.gocd_server.private_ip]
}

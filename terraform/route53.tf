
resource "aws_route53_record" "gocd_public" {
  zone_id = data.aws_ssm_parameter.public_zone_id.value
  name    = "${var.environment}.gocd.${var.root_domain}"
  type    = "A"
  ttl     = "3600"
  records = [aws_instance.gocd_server.public_ip]
}

# resource "aws_route53_record" "gocd_public_prod" {
#   zone_id = data.aws_ssm_parameter.public_com_zone_id.value
#   name    = "gocd.${var.root_domain}"
#   type    = "CNAME"
#   ttl     = "3600"
#   records = ["proxy.${var.root_domain}"]
#   count   = "${var.environment == "production" ? 1 : 0}"
# }

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
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-route53-zone-id"
  type = "String"
  value = aws_route53_zone.private.id
}

resource "aws_route53_record" "gocd_private" {
  zone_id = aws_route53_zone.private.id
  name    = "${var.environment}.gocd.${var.root_domain}"
  type    = "A"
  ttl     = "3600"
  records = [aws_instance.gocd_server.private_ip]
}

resource "aws_ram_resource_share" "gocd_for_gp2gp" {
  name                      = "gocd-subnet-for-gp2gp"
  allow_external_principals = false

  tags = {
    Environment = "dev and prod"
  }
}

resource "aws_ram_resource_association" "gocd_for_gp2gp" {
  resource_arn       = aws_subnet.private.arn
  resource_share_arn = aws_ram_resource_share.gocd_for_gp2gp.arn
}

resource "aws_ram_principal_association" "gocd_for_gp2gp_prod" {
  principal          = data.aws_ssm_parameter.gp2gp_prod_account_id.value
  resource_share_arn = aws_ram_resource_share.gocd_for_gp2gp.arn
}

resource "aws_ram_principal_association" "gocd_for_gp2gp_dev" {
  principal          = data.aws_ssm_parameter.gp2gp_dev_account_id.value
  resource_share_arn = aws_ram_resource_share.gocd_for_gp2gp.arn
}

data "aws_ssm_parameter" "gp2gp_prod_account_id" {
  name = "/registrations/prod/user-input/principal-account-id"
}

data "aws_ssm_parameter" "gp2gp_dev_account_id" {
  name = "/registrations/dev/user-input/principal-account-id"
}
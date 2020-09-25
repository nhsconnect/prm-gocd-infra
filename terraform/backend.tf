
terraform{
      backend "s3" {
        bucket  = "prm-deductions-terraform-state"
        key     = "gocd-infra/terraform.tfstate"
        region  = "eu-west-2"
        encrypt = true
    }
}

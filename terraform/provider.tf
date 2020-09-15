
# Setup AWS provider
provider "aws" {
  profile = "admin"
  version = "~> 2.27"
  region = var.region
}

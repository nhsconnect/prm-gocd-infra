# Setup AWS provider
provider "aws" {
  profile = "default"
  version = "3.44.0"
  region = var.region
}

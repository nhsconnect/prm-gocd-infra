variable "root_domain" {
  default = "patient-deductions.nhs.uk"
}

variable "agent_count" {
}

variable "agent_image_tag" {}

variable "environment" {}

variable "region" {
  default = "eu-west-2"
}

variable "repo_name" {
  type = string
  default = "prm-gocd-infra"
}

variable "server_flavor" {
  default = "t3a.small" # NB server needs about 2GB minimum RAM
}

variable "gocd_db_volume_size" {
  default = 60
}

variable "gocd_agent_volume_size" {
  default = 80
}

variable "agent_flavor" {
  default = "t3a.medium"
}

variable "vpc_cidr_block" {
  default = "10.1.0.0/16"
}

variable "public_subnet" {
  default = "10.1.100.0/24"
}
variable "db_subnet_a" {
  default = "10.1.1.0/24"
}
variable "db_subnet_b" {
  default = "10.1.2.0/24"
}
variable "private_subnet" {
  default = "10.1.3.0/24"
}

variable "az" {
  default = "eu-west-2a"
}

variable "vpn_client_subnet" {
  default = "10.233.216.0/22"
}

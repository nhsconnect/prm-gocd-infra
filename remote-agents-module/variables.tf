variable "environment" {}

variable "region" {
  default = "eu-west-2"
}

variable "az" {
  default = "eu-west-2a"
}

variable "agent_resources" {}

variable "subnet_id" {}

variable "vpc_id" {}

variable "allocate_public_ip" {}

variable "gocd_agent_volume_size" {
  default = 40
}

variable "agent_count" {
  default = 1
}

variable "agent_flavor" {
  default = "t3a.small"
}

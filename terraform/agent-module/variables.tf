variable "root_domain" {
  default = "patient-deductions.nhs.uk"
}

variable "agent_image_tag" {}

variable "agent_instance_profile" {}

variable "agent_keypair_name" {}

variable "environment" {}

variable "subnet_id" {}

variable "allocate_public_ip" {}

variable "agent_sg_id" {}

variable "region" {
  default = "eu-west-2"
}

variable "gocd_agent_volume_size" {
  default = 40
}

variable "agent_count" {
  default = 1
}

variable "agent_flavor" {
  default = "t3a.small"
}

variable "az" {
  default = "eu-west-2a"
}

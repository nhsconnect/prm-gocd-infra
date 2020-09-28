resource "aws_instance" "gocd_agent" {
  count         = var.agent_count
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = var.agent_flavor
  key_name      = var.agent_keypair_name

  # instance profile sufficient to access the ECR images, because we are pulling gocd agent image.
  iam_instance_profile = var.agent_instance_profile

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.gocd_agent_volume_size
    delete_on_termination = true
  }
  availability_zone = var.az

  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.allocate_public_ip # required for internet access until we have nat
  #TODO use NAT for agents

  vpc_security_group_ids = [
    var.agent_sg_id,
  ]

  tags = {
    Name        = "GoCD agent ${count.index} VM ${var.environment}"
    CreatedBy   = "prm-gocd-infra"
    Environment = var.environment
    Service     = "GoCD"
  }

  user_data            = data.template_file.agent_userdata.rendered
}

resource "aws_ssm_parameter" "agent_ips" {
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-agent-ips"
  type = "String"
  value = join(",", aws_instance.gocd_agent.*.public_ip)
}

data "template_file" "agent_userdata" {
  template = "${file("${path.module}/templates/bootstrap-agent.sh")}"

  vars = {
    GOCD_ENVIRONMENT = var.environment
    AWS_REGION = var.region
    GOCD_AGENT_IMAGE_TAG = var.agent_image_tag
    AGENT_RESOURCES = var.agent_resources
  }
}

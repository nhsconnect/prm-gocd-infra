resource "aws_instance" "gocd_agent" {
  count         = var.agent_count
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = var.agent_flavor
  key_name      = aws_key_pair.gocd.key_name

  # instance profile sufficient to access the ECR images, because we are pulling gocd agent image.
  iam_instance_profile = aws_iam_instance_profile.gocd_agent.name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.gocd_agent_volume_size
    delete_on_termination = true
  }
  availability_zone = var.az

  subnet_id                   = local.subnet_id
  associate_public_ip_address = true # required for internet access until we have nat
  #TODO use NAT for agents

  vpc_security_group_ids = [
    aws_security_group.go_agent_sg.id,
  ]

  tags = {
    Name        = "GoCD agent ${count.index} VM ${var.environment}"
    CreatedBy   = "prm-gocd-infra"
    Environment = var.environment
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = local.remote_user
    private_key = local.private_key
  }

  user_data            = "${data.template_file.agent_userdata.rendered}"
}

data "template_file" "agent_userdata" {
  template = "${file("${path.module}/templates/bootstrap-agent.sh")}"

  vars = {
    GOCD_ENVIRONMENT = var.environment
    AWS_REGION = var.region
    GOCD_AGENT_IMAGE_TAG = var.agent_image_tag
  }
}

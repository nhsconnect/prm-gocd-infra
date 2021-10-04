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
    encrypted = true
  }

  volume_tags = {
    Name        = "GoCD agent ${count.index} VM ${var.environment}: ${var.agent_resources}"
    CreatedBy = var.repo_name
    Environment = var.environment
  }

  availability_zone = var.az

  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.allocate_public_ip

  vpc_security_group_ids = [
    var.agent_sg_id,
    var.agent_repo_services_sg_id
  ]

  tags = {
    Name        = "GoCD agent ${count.index} VM ${var.environment}"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }

  user_data            = data.template_file.agent_userdata.rendered
}

data "template_file" "agent_userdata" {
  template = "${file("${path.module}/templates/bootstrap-agent.sh")}"

  vars = {
    GOCD_ENVIRONMENT = var.environment
    AWS_REGION = var.region
    GOCD_AGENT_IMAGE_TAG = var.agent_image_tag
    AGENT_RESOURCES = var.agent_resources
    SSM_CLOUDWATCH_CONFIG = aws_ssm_parameter.cw_agent.name
  }
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to publish gocd-agents log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("${path.module}/cw_agent_config.json")
}

resource "aws_cloudwatch_log_group" "gocd" {
  name = "gocd-instances-user-data-logs"
}

resource "aws_cloudwatch_log_group" "gocd-agent" {
  name = "gocd-instances-agent-logs"
}

resource "aws_cloudwatch_log_group" "gocd-agent-error" {
  name = "gocd-instances-agent-error-logs"
}

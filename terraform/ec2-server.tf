resource "aws_instance" "gocd_server" {
  ami                   = data.aws_ami.amazon-linux-2.id
  instance_type         = var.server_flavor
  availability_zone     = var.az
  subnet_id             = local.private_subnet_id
  ebs_optimized         = true
  vpc_security_group_ids = [
    aws_security_group.gocd_server.id
  ]
  associate_public_ip_address = false
  root_block_device {
    encrypted = true
  }

  key_name = aws_key_pair.gocd.key_name

  tags = {
    Name        = "GoCD server VM ${var.environment}"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
//TODO Change the root disk size to 16 as it should be 8 now in terraform.
resource "aws_ebs_volume" "gocd_db" {
  tags = {
    Name = "GoCD DB ${var.environment} data and artifacts"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
  availability_zone = var.az
  size              = var.gocd_db_volume_size
  encrypted = true
}

resource "aws_volume_attachment" "db_att" {
  volume_id   = aws_ebs_volume.gocd_db.id
  instance_id = aws_instance.gocd_server.id
  device_name = "/dev/sdf"
}

resource "aws_instance" "gocd_server" {
  ami                   = "${data.aws_ami.amazon-linux-2.id}"
  instance_type         = var.server_flavor
  availability_zone     = var.az
  subnet_id             = local.subnet_id
  vpc_security_group_ids = [
    data.aws_ssm_parameter.dynamic_gocd_sg.value,
    aws_security_group.gocd_server.id
  ]
  associate_public_ip_address = true

  key_name = aws_key_pair.gocd.key_name

  tags = {
    Name        = "GoCD server VM ${var.environment}"
    CreatedBy   = "prm-gocd-infra"
    Environment = var.environment
    Service     = "GoCD"
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = local.remote_user
    private_key = local.private_key
  }

  provisioner "remote-exec" {
    script = "./bootstrap.sh"
  }
}

resource "aws_ebs_volume" "gocd_db" {
  tags = {
    Name = "GoCD DB ${var.environment} data and artifacts"
  }
  availability_zone = var.az
  size              = var.gocd_db_volume_size
}

resource "aws_volume_attachment" "db_att" {
  volume_id   = "${aws_ebs_volume.gocd_db.id}"
  instance_id = "${aws_instance.gocd_server.id}"
  device_name = "/dev/sdf"

  # Stop DB and umount the filesystem before detaching the volume
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = local.remote_user
      private_key = local.private_key
      host     = "${aws_instance.gocd_server.public_ip}"
    }
    when    = "destroy"
    inline = [
      "sudo docker stop db || true",
      "sudo umount /var/gocd-data || true"
    ]
  }
}

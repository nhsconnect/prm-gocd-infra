locals {
  private_key = "${file("${path.module}/ssh/gocd-${var.environment}")}"
  subnet_id = aws_subnet.public-subnet.id
  remote_user = "ec2-user"
}

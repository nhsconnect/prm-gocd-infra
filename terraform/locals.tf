locals {
  private_key = "${file("${path.module}/ssh/gocd-${var.environment}")}"
  private_subnet_id = aws_subnet.private.id
  subnet_id = aws_subnet.public-subnet.id
  remote_user = "ec2-user"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "GoCD ${var.environment} gateway"
  }
}
#TODO: use NAT and private subnet instead of internet gateway

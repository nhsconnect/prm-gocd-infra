resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "GoCD ${var.environment} gateway"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
#TODO: use NAT and private subnet instead of internet gateway

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "GoCD public subnet"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

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

resource "aws_subnet" "db_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.db_subnet_a
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "GoCD database subnet"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_subnet" "db_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.db_subnet_b
  availability_zone       = "eu-west-2b"

  tags = {
    Name = "GoCD database subnet"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet
  availability_zone       = var.az

  tags = {
    Name = "GoCD private subnet"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}


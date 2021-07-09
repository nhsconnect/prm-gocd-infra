resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "GoCD-${var.environment}-public"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }

  lifecycle {
    # Because other deductions VPC modify the routing table
    ignore_changes = [
      route
    ]
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_ssm_parameter" "route_table_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/gocd-route-table-id"
  type  = "String"
  value = aws_route_table.private.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    nat_gateway_id = aws_nat_gateway.gocd_agent.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "GoCD-${var.environment}-private"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }

  lifecycle {
    # Because other deductions VPC modify the routing table
    ignore_changes = [
      route
    ]
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


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
  name = "/repo/${var.environment}/prm-gocd-infra/output/gocd-route-table-id"
  type  = "String"
  value = aws_route_table.public.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

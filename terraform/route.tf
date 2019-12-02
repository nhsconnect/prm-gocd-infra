resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    gateway_id = "${aws_internet_gateway.igw.id}"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "GoCD-${var.environment}-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_ssm_parameter" "route_table_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-${var.environment}/route_table_id"
  type  = "String"
  value = aws_route_table.public.id
}

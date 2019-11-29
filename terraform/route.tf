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

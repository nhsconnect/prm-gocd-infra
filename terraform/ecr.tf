
resource "aws_ecr_repository" "gocd-agent" {
  name = "gocd-agent"
  tags = {
    Name = "GoCD agent ${var.environment}"
  }
}


resource "aws_key_pair" "gocd" {
  key_name   = "gocd-${var.environment}-key"
  public_key = file("${path.module}/ssh/gocd-${var.environment}.pub")
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

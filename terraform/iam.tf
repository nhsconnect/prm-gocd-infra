data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gocd_agent" {
  name                 = "gocd_agent-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.instance-assume-role-policy.json
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_iam_instance_profile" "gocd_agent" {
  name = "gocd_agent-${var.environment}"
  role = aws_iam_role.gocd_agent.name
}

#TODO: other permissions for GoCD server, agent
# Agent builds and pushes images to ECR
resource "aws_iam_role_policy_attachment" "agent-ecr-attach" {
  role       = aws_iam_role.gocd_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Agent to access the SSM secrets
resource "aws_iam_role_policy_attachment" "agent-ssm-attach" {
  role       = aws_iam_role.gocd_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Agent provisions all infrastructure in AWS - must allow full perms
resource "aws_iam_role_policy_attachment" "agent-admin-attach" {
  role       = aws_iam_role.gocd_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gocd_server" {
  name                 = "gocd_server-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_instance_profile" "gocd_server" {
  name = "gocd_server-${var.environment}"
  role = aws_iam_role.gocd_server.name
}

resource "aws_iam_role" "gocd_agent" {
  name                 = "gocd_agent-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_instance_profile" "gocd_agent" {
  name = "gocd_agent-${var.environment}"
  role = aws_iam_role.gocd_agent.name
}

# Server instance needs to pull the GoCD docker image
resource "aws_iam_role_policy_attachment" "server-ecr-attach" {
  role       = aws_iam_role.gocd_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#TODO: other permissions for GoCD server, agent
# Agent builds and pushes images to ECR
resource "aws_iam_role_policy_attachment" "agent-ecr-attach" {
  role       = aws_iam_role.gocd_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

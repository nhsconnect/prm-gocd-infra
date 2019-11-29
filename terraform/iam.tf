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

#For DNS challenge and ssl certs
#FIXME: restrict access to public zone only
resource "aws_iam_role_policy_attachment" "server-r53-attach" {
  role       = aws_iam_role.gocd_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
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

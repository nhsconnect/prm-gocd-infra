# The role of GoCD agents in the CI account
data "aws_ssm_parameter" "gocd_trusted_principal" {
  name = "/repo/user-input/external/gocd-trusted-principal"
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_ssm_parameter.gocd_trusted_principal.value]
    }
  }
}

resource "aws_iam_role" "ci_agent" {
  name               = "repository-ci-agent"
  description        = "Role to assume from the CI account"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.ci_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

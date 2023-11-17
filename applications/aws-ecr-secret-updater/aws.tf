resource "aws_iam_user" "default" {
  name = "aws-secret-updater"
}

resource "aws_iam_access_key" "default" {
  user = aws_iam_user.default.name
}

data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "default" {
  name    = "aws-secret-updater-policy"
  policy  = data.aws_iam_policy_document.default.json
  user    = aws_iam_user.default.name
}
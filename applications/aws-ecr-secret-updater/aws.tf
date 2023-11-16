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
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "default" {
  name    = "aws-secret-updater-policy"
  policy  = data.aws_iam_policy_document.default.json
  user    = aws_iam_user.default.name
}
resource "aws_ecr_repository" "default" {
  name = "lutergs-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "최근 5개 이미지만 유지",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}


// aws trust policy
data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [var.aws.github-oidc-provider.arn]
      # identifiers = [aws_iam_openid_connect_provider.github-oidc-provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${trimprefix(var.aws.github-oidc-provider.url, "https://")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "${trimprefix(var.aws.github-oidc-provider.url, "https://")}:sub"
      values   = ["repo:${github_repository.default.full_name}:*"]
    }
  }
}

// aws IAM policy
data "aws_iam_policy_document" "default_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [aws_ecr_repository.default.arn]
  }
  statement {
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

// create role of github actions
resource "aws_iam_role" "default_role" {
  name = "github-repo-lutergs-backend"
  description = "role of github actions in repo lutergs-backend"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  inline_policy {
    name = "default-policy"
    policy = data.aws_iam_policy_document.default_policy.json
  }
}
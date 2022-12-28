#########################################
#
# SOPS
#
#########################################
data "sops_file" "secrets" {
  source_file = "secrets.yml"
}

#########################################
#
# KMS
#
#########################################
data "aws_kms_key" "main" {
  key_id = "alias/main"
}

#########################################
#
# IAM Assum Role Policy
#
#########################################
data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "gihub_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = ["arn:aws:iam::292687378741:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:nysdin/redash_fargate:*"]
    }
  }
}

#########################################
#
# IAM Policy Document
#
#########################################
data "aws_iam_policy_document" "redash_secret" {
  statement {
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]

    resources = [
      aws_ssm_parameter.redash_postgresql_url.arn,
      aws_ssm_parameter.redash_redis_url.arn,
      aws_ssm_parameter.mackerel_apikey.arn
    ]
  }
}

data "aws_iam_policy_document" "ecs_exec" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "redash_fargate_pipeline" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]

    resources = ["*"]
  }

  statement {
    actions = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test = "StringEqualsIfExists"
      variable = "iam:PassedToService"

      values = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    actions = [
      "codedeploy:*",
      "cloudwatch:*",
      "ecs:*",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "gh_ecs_deploy_policy" {
  statement {
    sid = "RegisterTaskDefinition"
    actions = [
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    sid = "PassRolesInTaskDefinition"
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.redash_ecs_task_role.arn,
      aws_iam_role.redash_ecs_task_execution_role.arn
    ]
  }

  statement {
    sid = "DeployService"
    actions = [
      "ecs:DescribeServices",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    # resources = [aws_ecs_service.redash.id] <= CodeDeployもtf管理したらdeploymentgroupなどのリソースを指定する
    resources = ["*"]
  }
}

#########################################
#
# IAM Policy (Service Role)
#
#########################################
data "aws_iam_policy" "amazon_ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

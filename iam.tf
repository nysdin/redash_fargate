#########################################
#
# IAM Role & IAM Role Policy Attachment
#
#########################################

resource "aws_iam_role" "redash_ecs_task_execution_role" {
  name               = "redashEcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "redash_secret" {
  role       = aws_iam_role.redash_ecs_task_execution_role.name
  policy_arn = aws_iam_policy.redash_secret_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_ecs_task_execution_role_policy" {
  role       = aws_iam_role.redash_ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn
}

resource "aws_iam_role" "redash_ecs_task_role" {
  name               = "redashEcsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.redash_ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

resource "aws_iam_role" "redash_fargate_pipeline_role" {
  name = "redash-fargate-CodePipelineRole"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "redash_fargate_pipeline" {
  role = aws_iam_role.redash_fargate_pipeline_role.name
  policy_arn = aws_iam_policy.redash_fargate_pipeline_policy.arn
}

resource "aws_iam_role" "githubactions" {
  name = "redash-fargate-gh-actions"
  assume_role_policy = data.aws_iam_policy_document.gihub_actions_assume_role_policy.json
}

#########################################
#
# IAM Policy
#
#########################################

resource "aws_iam_policy" "redash_secret_policy" {
  name   = "redash_secret_policy"
  policy = data.aws_iam_policy_document.redash_secret.json
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name   = "ecs_exec_policy"
  policy = data.aws_iam_policy_document.ecs_exec.json
}

resource "aws_iam_policy" "redash_fargate_pipeline_policy" {
  name = "redash-fargate-CodePipelinePolicy"
  policy = data.aws_iam_policy_document.redash_fargate_pipeline.json
}

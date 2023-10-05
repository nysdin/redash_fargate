# medmed-bot 用 Lambda のバージョンの description に docker image のタグ値を記載するのが良さそう
resource "aws_lambda_function" "gh_actions_dispatcher" {
  function_name = "gh-actions-dispatcher"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.gh_actions_dispatcher.repository_url}:latest"
  role          = data.aws_iam_role.aws_lambda_basic_execution_role.arn
}

resource "aws_lambda_permission" "gh_actions_dispatcher_allow_apigateawy" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gh_actions_dispatcher.function_name
  principal     = "apigateway.amazonaws.com"

  # Without this, any resource from principal will be granted permission – even if that resource is from another account.
  source_arn = "${aws_api_gateway_rest_api.gh_actions_dispatcher.execution_arn}/*"
}

resource "aws_lambda_alias" "gh_actions_dispatcher_dev" {
  name             = "dev"
  function_name    = aws_lambda_function.gh_actions_dispatcher.arn
  function_version = "$LATEST"
}

resource "aws_api_gateway_rest_api" "gh_actions_dispatcher" {
  name = "gh-actions-dispacther"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# /deploy
resource "aws_api_gateway_resource" "deploy" {
  parent_id   = aws_api_gateway_rest_api.gh_actions_dispatcher.root_resource_id
  path_part   = "deploy"
  rest_api_id = aws_api_gateway_rest_api.gh_actions_dispatcher.id
}

# Method Request に関するリソース
## POST /deploy
resource "aws_api_gateway_method" "deploy_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.gh_actions_dispatcher.id
}

# Integration Request に関するリソース
## POST /deploy
resource "aws_api_gateway_integration" "deploy_post_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.gh_actions_dispatcher.id
  resource_id             = aws_api_gateway_resource.deploy.id
  http_method             = aws_api_gateway_method.deploy_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.gh_actions_dispatcher.invoke_arn
  request_templates = {
    "application/x-www-form-urlencoded" = <<EOF
## convert HTML POST data or HTTP GET query string to JSON

## get the raw post data from the AWS built-in variable and give it a nicer name
#if ($context.httpMethod == "POST")
  #set($rawAPIData = $input.path("$"))
#elseif ($context.httpMethod == "GET")
  #set($rawAPIData = $input.params().querystring)
  #set($rawAPIData = $rawAPIData.toString())
  #set($rawAPIDataLength = $rawAPIData.length() - 1)
  #set($rawAPIData = $rawAPIData.substring(1, $rawAPIDataLength))
  #set($rawAPIData = $rawAPIData.replace(", ", "&"))
#else
  #set($rawAPIData = "")
#end

## first we get the number of "&" in the string, this tells us if there is more than one key value pair
#set($countAmpersands = $rawAPIData.length() - $rawAPIData.replace("&", "").length())

## if there are no "&" at all then we have only one key value pair.
## we append an ampersand to the string so that we can tokenise it the same way as multiple kv pairs.
## the "empty" kv pair to the right of the ampersand will be ignored anyway.
#if ($countAmpersands == 0)
  #set($rawPostData = $rawAPIData + "&")
#end

## now we tokenise using the ampersand(s)
#set($tokenisedAmpersand = $rawAPIData.split("&"))

## we set up a variable to hold the valid key value pairs
#set($tokenisedEquals = [])

## now we set up a loop to find the valid key value pairs, which must contain only one "="
#foreach( $kvPair in $tokenisedAmpersand )
  #set($countEquals = $kvPair.length() - $kvPair.replace("=", "").length())
  #if ($countEquals == 1)
    #set($kvTokenised = $kvPair.split("="))
    #if ( ( $kvTokenised[0].length() > 0 ) && ( $kvTokenised[1].length() > 0 ) )
      ## we found a valid key value pair. add it to the list.
      #set($devNull = $tokenisedEquals.add($kvPair))
    #end
  #end
#end

## next we set up our loop inside the output structure "{" and "}"
{
#foreach( $kvPair in $tokenisedEquals )
  ## finally we output the JSON for this pair and append a comma if this isn't the last pair
  #set($kvTokenised = $kvPair.split("="))
  "$util.urlDecode($kvTokenised[0])" : #if($kvTokenised.size() > 1 && $kvTokenised[1].length() > 0)"$util.urlDecode($kvTokenised[1])"#{else}""#end#if( $foreach.hasNext ),#end
#end
}
EOF
  }
}

# Method Response に関するリソース
## POST /deploy
## GUI から設定すると自動で作成されるのリソースだったので IaC 化する場合は忘れないように作成すること
resource "aws_api_gateway_integration_response" "deploy_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.gh_actions_dispatcher.id
  resource_id = aws_api_gateway_resource.deploy.id
  http_method = aws_api_gateway_method.deploy_post.http_method
  status_code = aws_api_gateway_method_response.deploy_post.status_code
}

# Method Response に関するリソース
## POST /deploy
## GUI から設定すると自動で作成されるのリソースだったので IaC 化する場合は忘れないように作成すること
resource "aws_api_gateway_method_response" "deploy_post" {
  rest_api_id = aws_api_gateway_rest_api.gh_actions_dispatcher.id
  resource_id = aws_api_gateway_resource.deploy.id
  http_method = aws_api_gateway_method.deploy_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

# どの stage にも関連付けられていない deploy を作成する
# stage との関連付けは `aws_api_gateway_stage` リソースで行う
resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.gh_actions_dispatcher.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.deploy.id,
      aws_api_gateway_method.deploy_post.id,
      aws_api_gateway_method_response.deploy_post.id,
      aws_api_gateway_integration.deploy_post_lambda.id,
      aws_api_gateway_integration_response.deploy_post_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.gh_actions_dispatcher.id
  stage_name    = "default"
}

# -------- #


resource "aws_api_gateway_rest_api" "medmed_bot" {
  name = "medmed-bot"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "medmeed_bot_deploy" {
  parent_id   = aws_api_gateway_rest_api.medmed_bot.root_resource_id
  path_part   = "deploy"
  rest_api_id = aws_api_gateway_rest_api.medmed_bot.id
}

resource "aws_api_gateway_method" "medmeed_bot_deploy_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.medmeed_bot_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.medmed_bot.id
}

resource "aws_api_gateway_integration" "medmed_bot_deploy_post_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.medmed_bot.id
  resource_id             = aws_api_gateway_resource.medmeed_bot_deploy.id
  http_method             = aws_api_gateway_method.medmeed_bot_deploy_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-northeast-1:292687378741:function:gh-actions-dispatcher:$${stageVariables.alias}/invocations"
}

resource "aws_api_gateway_method_response" "medmed_bot_deploy_post" {
  rest_api_id = aws_api_gateway_rest_api.medmed_bot.id
  resource_id = aws_api_gateway_resource.medmeed_bot_deploy.id
  http_method = aws_api_gateway_method.medmeed_bot_deploy_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

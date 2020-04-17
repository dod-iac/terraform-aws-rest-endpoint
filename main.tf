/**
 * ## Usage
 *
 * Creates an AWS API Gateway REST API with one endpoint that submits data to an AWS Lambda function.  The API supports CORS.  Using the given Lambda function name, this module adds an `aws_lambda_permission` to allow the REST API to invoke the Lambda.
 *
 * ```hcl
 * module "rest_endpoint" {
 *   source = "dod-iac/rest-endpoint/aws"
 *
 *   name                 = format("api-%s-%s", var.application, var.environment)
 *   path_part            = "submit"
 *   lambda_invoke_arn    = module.lambda_submit_function.lambda_invoke_arn
 *   lambda_function_name = module.lambda_submit_function.lambda_function_name
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * Once the REST API is created, to avoid an inconsistent terraform state, manually deploy the REST by using the `deploy-api` script, e.g., `scripts/deploy-api us-west-2 api-hello-experimental experimental`.
 *
 * ## Terraform Version
 *
 * Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 is not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_api_gateway_rest_api" "main" {
  name = var.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = var.tags
}

resource "aws_api_gateway_resource" "submit" {
  path_part   = var.path_part
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "submit_options" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.submit.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = var.api_key_required
  request_parameters = {
    "method.request.header.Access-Control-Request-Headers" = false
  }
}

resource "aws_api_gateway_method_response" "submit_options_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.submit_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "submit_options" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.submit.id
  http_method          = aws_api_gateway_method.submit_options.http_method
  type                 = "MOCK"
  timeout_milliseconds = var.timeout_milliseconds
  cache_key_parameters = []
  #request_parameters   = {}
  request_templates = {
    "application/json" = <<-EOF
    {"statusCode": 200}
    #set($context.requestOverride.header.Access-Control-Request-Headers = "$input.params().header.get('Access-Control-Request-Headers')")
    EOF
  }
}

resource "aws_api_gateway_integration_response" "submit_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.submit_options.http_method
  status_code = aws_api_gateway_method_response.submit_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "context.requestOverride.header.Access-Control-Request-Headers"
    "method.response.header.Access-Control-Allow-Methods" = "'*'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_method" "submit_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.submit.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = var.api_key_required
}

resource "aws_api_gateway_integration" "submit_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.submit.id
  http_method             = aws_api_gateway_method.submit_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  timeout_milliseconds    = var.timeout_milliseconds
  uri                     = var.lambda_invoke_arn
}

resource "aws_lambda_permission" "apigateway_lambda_submit" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # source_arn derived from this page
  # http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = format(
    "arn:%s:execute-api:%s:%s:%s/*/%s%s",
    data.aws_partition.current.partition,
    data.aws_region.current.name,
    data.aws_caller_identity.current.account_id,
    aws_api_gateway_rest_api.main.id,
    aws_api_gateway_method.submit_post.http_method,
    aws_api_gateway_resource.submit.path
  )
}

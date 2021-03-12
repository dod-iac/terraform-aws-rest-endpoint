<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates an AWS API Gateway REST API with one endpoint that submits data to an AWS Lambda function.  The API supports CORS.  Using the given Lambda function name, this module adds an `aws_lambda_permission` to allow the REST API to invoke the Lambda.

```hcl
module "rest_endpoint" {
  source = "dod-iac/rest-endpoint/aws"

  name                 = format("api-%s-%s", var.application, var.environment)
  path_part            = "submit"
  lambda_invoke_arn    = module.lambda_submit_function.lambda_invoke_arn
  lambda_function_name = module.lambda_submit_function.lambda_function_name
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

Once the REST API is created, to avoid an inconsistent terraform state, manually deploy the REST by using the `deploy-api` script, e.g., `scripts/deploy-api us-west-2 api-hello-experimental experimental`.

## Terraform Version

Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 is not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_api_gateway_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) |
| [aws_api_gateway_integration_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) |
| [aws_api_gateway_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) |
| [aws_api_gateway_method_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) |
| [aws_api_gateway_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) |
| [aws_api_gateway_rest_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) |
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) |
| [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api\_key\_required | Specify if the method requires an API key. | `bool` | `false` | no |
| lambda\_function\_name | The unique name for your Lambda Function. | `string` | n/a | yes |
| lambda\_invoke\_arn | The Amazon Resource Name (ARN) to be used for invoking the Lambda Function from API Gateway. | `string` | n/a | yes |
| name | Name of the AWS API Gateway REST API. | `string` | n/a | yes |
| path\_part | The last path segment of this API resource. | `string` | n/a | yes |
| tags | Tags applied to the AWS API Gateway REST API. | `map(string)` | `{}` | no |
| timeout\_milliseconds | Custom timeout between 50 and 29,000 milliseconds. | `number` | `"29000"` | no |

## Outputs

| Name | Description |
|------|-------------|
| rest\_api\_arn | The Amazon Resource Name (ARN) of the AWS API Gateway REST API. |
| rest\_api\_id | The ID of the AWS API Gateway REST API. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

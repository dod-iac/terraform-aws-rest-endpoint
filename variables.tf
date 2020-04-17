variable "api_key_required" {
  type        = bool
  description = "Specify if the method requires an API key."
  default     = false
}

variable "name" {
  type        = string
  description = "Name of the AWS API Gateway REST API."
}

variable "lambda_function_name" {
  type        = string
  description = "The unique name for your Lambda Function."
}

variable "lambda_invoke_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) to be used for invoking the Lambda Function from API Gateway."
}

variable "path_part" {
  type        = string
  description = "The last path segment of this API resource."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the AWS API Gateway REST API."
  default     = {}
}

variable "timeout_milliseconds" {
  type        = number
  description = "Custom timeout between 50 and 29,000 milliseconds."
  default     = "29000"
}

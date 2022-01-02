# Input variable definitions

variable "aws_access_key" {
  description = "localstack fake AWS access key"
  type        = string
  default     = "localstack"
}

variable "aws_secret_key" {
  description = "localstack fake AWS secret key"
  type        = string
  default     = "localstack"
}

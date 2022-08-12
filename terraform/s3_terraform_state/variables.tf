variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "AWS region for provisioning"
}

variable "aws_profile" {
  default     = "default"
  description = "AWS profile using for connect to AWS"
}

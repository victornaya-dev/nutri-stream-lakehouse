variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nutri-stream"
}

variable "bucket_raw" {
  description = "S3 raw bucket name"
  type        = string
}

variable "bucket_processed" {
  description = "S3 processed bucket name"
  type        = string
}

variable "kinesis_stream_name" {
  description = "Kinesis Data Stream name"
  type        = string
  default     = "food-facts-stream"
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis Data Stream"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  sensitive   = true
}

variable "firehose_role_arn" {
  description = "Firehose service role ARN"
  type        = string
  sensitive   = true
}
variable "aws_region" {
  default = "eu-west-1"
}

variable "project_name" {
  default = "nutri-stream"
}


variable "bucket_raw" {
  default = "food-facts-raw-victor"
}

variable "bucket_processed" {
  default = "food-facts-processed-victor"
}

variable "kinesis_stream_name" {
  default = "food-facts-stream"
}

variable "kinesis_stream_arn" {
  default = ""
}

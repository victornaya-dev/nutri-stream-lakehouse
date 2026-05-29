resource "aws_kinesis_stream" "main" {
  name                   = var.kinesis_stream_name
  retention_period       = 24
  shard_count            = 1

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }

}



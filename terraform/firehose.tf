resource "aws_kinesis_firehose_delivery_stream" "food_facts_delivery_stream" {
  name        = "food-facts-delivery-stream"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = "arn:aws:kinesis:eu-west-1:${var.aws_account_id}:stream/food-facts-stream"
    role_arn           = var.firehose_role_arn
  }

  extended_s3_configuration {
    bucket_arn         = "arn:aws:s3:::food-facts-raw-victor"
    role_arn           = var.firehose_role_arn
    buffering_interval = 60
    buffering_size     = 5
    compression_format = "GZIP"
    prefix             = "kinesis/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "kinesis-errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/food-facts-delivery-stream"
      log_stream_name = "DestinationDelivery"
    }

    processing_configuration {
      enabled = false
    }
  }

  server_side_encryption {
    enabled = false
  }
}
resource "aws_glue_crawler" "json_crawler" {
  name          = "food-facts-crawler"
  database_name = "food_facts_db"
  role          = aws_iam_role.glue_role.name

  configuration = jsonencode({
    Version              = 1.0
    CreatePartitionIndex = true
  })

  s3_target {
    path = "s3://${var.bucket_raw}/cleaned/"
  }
}

resource "aws_glue_crawler" "parquet_crawler" {
  name          = "food-facts-parquet-crawler"
  database_name = "food_facts_db"
  role          = aws_iam_role.glue_role.name

  configuration = jsonencode({
    Version              = 1.0
    CreatePartitionIndex = true
  })

  s3_target {
    path = "s3://${var.bucket_processed}/parquet/"
  }
}


resource "aws_glue_catalog_database" "food_facts" {
  name = "food_facts_db"
}


resource "aws_glue_job" "etl" {
  name              = "food-facts-etl"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "5.1"
  worker_type       = "G.1X"
  number_of_workers = 10
  timeout           = 480
  execution_class   = "STANDARD"

  command {
    script_location = "s3://aws-glue-assets-${var.aws_account_id}-eu-west-1/scripts/food-facts-etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                          = "s3://aws-glue-assets-${var.aws_account_id}-eu-west-1/temporary/"
    "--conf"                             = "spark.eventLog.rolling.enabled=true --conf spark.sql.catalog.glue_catalog.glue.skip-name-validation=true"
    "--enable-glue-datacatalog"          = "true"
    "--enable-job-insights"              = "true"
    "--enable-observability-metrics"     = "true"
    "--enable-spark-ui"                  = "true"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--spark-event-logs-path"            = "s3://aws-glue-assets-${var.aws_account_id}-eu-west-1/sparkHistoryLogs/"
    "--output_path"                      = "s3://${var.bucket_processed}/parquet/"
  }
}

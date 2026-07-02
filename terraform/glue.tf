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
  depends_on = [aws_s3_bucket.raw]
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
  depends_on = [aws_s3_bucket.processed]

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
    script_location = "s3://${var.bucket_raw}/scripts/glue_etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                          = "s3://${var.bucket_raw}/temporary/"
    "--conf"                             = "spark.eventLog.rolling.enabled=true --conf spark.sql.catalog.glue_catalog.glue.skip-name-validation=true"
    "--enable-glue-datacatalog"          = "true"
    "--enable-job-insights"              = "true"
    "--enable-observability-metrics"     = "true"
    "--enable-spark-ui"                  = "true"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--spark-event-logs-path"            = "s3://${var.bucket_raw}/sparkHistoryLogs/"
    "--output_path"                      = "s3://${var.bucket_processed}/parquet/"
  }
}


resource "aws_s3_object" "glue_script" {
  bucket = var.bucket_raw
  key    = "scripts/glue_etl.py"
  source = "${path.module}/../src/glue_etl.py"
  etag   = filemd5("${path.module}/../src/glue_etl.py")
  depends_on = [aws_s3_bucket.raw]
}
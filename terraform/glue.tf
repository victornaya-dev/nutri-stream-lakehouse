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
  name = "food-facts-parquet-crawler"
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

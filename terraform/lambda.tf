resource "aws_lambda_function" "transform" {
  function_name = "food-facts-transform"
  handler       = "lambda_transform.lambda_handler"
  runtime       = "python3.14"
  role          = aws_iam_role.lambda_role.arn

  filename         = "../src/lambda_transform.zip"
  source_code_hash = filebase64sha256("../src/lambda_transform.zip")

  architectures = ["x86_64"]
  memory_size   = 128
  timeout       = 30
}

resource "aws_lambda_event_source_mapping" "kinesis_trigger" {
  event_source_arn  = var.kinesis_stream_arn
  function_name     = aws_lambda_function.transform.arn
  starting_position = "LATEST"
  batch_size        = 100
  enabled           = true

  depends_on = [aws_lambda_function.transform]
}
resource "aws_s3_bucket" "redash_fargate_artifact" {
  bucket = "redash-fargate-artifact"
}

resource "aws_s3_bucket" "nysdin_fluentbit_config" {
  bucket = "nysdin-aws-for-fluent-bit-config"
}

resource "aws_s3_object" "nysdin_fluentbit_log_destinations_config" {
  bucket = aws_s3_bucket.nysdin_fluentbit_config.bucket
  key    = "outputs.conf"
  source = "templates/aws-for-fluent-bit/outputs.conf"
  etag   = filemd5("templates/aws-for-fluent-bit/outputs.conf")
}

resource "aws_s3_object" "nysdin_fluentbit_parsers_config" {
  bucket = aws_s3_bucket.nysdin_fluentbit_config.bucket
  key    = "parsers.conf"
  source = "templates/aws-for-fluent-bit/parsers.conf"
  etag   = filemd5("templates/aws-for-fluent-bit/parsers.conf")
}

resource "aws_s3_object" "nysdin_fluentbit_filters_config" {
  bucket = aws_s3_bucket.nysdin_fluentbit_config.bucket
  key    = "filters.conf"
  source = "templates/aws-for-fluent-bit/filters.conf"
  etag   = filemd5("templates/aws-for-fluent-bit/filters.conf")
}

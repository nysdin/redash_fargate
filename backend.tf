terraform {
  backend "s3" {
    bucket         = "nysdin-tf-state"
    dynamodb_table = "my-lock-table"
    encrypt        = true
    key            = "redash_fargate/test/terraform.tfstate"
    region         = "ap-northeast-1"
    profile        = "nysdin"
  }
}

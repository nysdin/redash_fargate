terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.36.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.6"
    }
  }
}

provider "aws" {
  profile = "nysdin"
  region  = "ap-northeast-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "production"
      Project     = "redash"
    }
  }
}


provider "sops" {}

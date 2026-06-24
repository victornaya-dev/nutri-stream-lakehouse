terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "food-facts-raw-victor"
    key    = "terraform/state/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}
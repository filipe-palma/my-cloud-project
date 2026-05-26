terraform {
  required_version = ">= 1.9.0"

backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "eu-central-1"
}

# Recurso de exemplo (um S3 bucket simples)
resource "aws_s3_bucket" "lab11" {
  bucket = "lab11-demo-${random_id.suffix.hex}"

  tags = {
    Lab = "11"
    ManagedBy = "Terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
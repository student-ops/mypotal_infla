terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.22.0"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

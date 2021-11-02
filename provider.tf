terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.59.0"
    }
  }

  backend "s3" {
    bucket = "ece592-automation-rechinj"
    key    = "state.week9"
    region = "us-east-1"
  }

}

provider "aws" {
  region  = "us-east-1"
  profile = "default" # From a ~/.aws/credentials file.
}


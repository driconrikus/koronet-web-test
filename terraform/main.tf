terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
     bucket = "koronet-terraform-state"
     key    = "koronet/terraform.tfstate"
     region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "koronet-web-server"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

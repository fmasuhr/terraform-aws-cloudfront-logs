terraform {
  required_version = "~> 0.14"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }
  }
}

terraform {
  required_version = ">= 1.8.4, < 2.0.0"

  required_providers {
    aws = {
      version = "~> 5.73"
      source  = "hashicorp/aws"
    }

    http = {
      version = "~> 3.4"
      source  = "hashicorp/http"
    }

    cloudinit = {
      version = "~> 2.3"
      source  = "hashicorp/cloudinit"
    }
  }

  backend "s3" {
    bucket = "john-bucket-terraform-state"
    key    = "learn-k8s-the-hard-way.tfstate"
    region = "eu-west-1"
  }
}

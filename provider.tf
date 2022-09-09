terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
#    serverscom = {
#      source = "serverscom/serverscom"
#      version = "0.2.3"
#    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Configure Serverscom provider
#provider "serverscom" {
  # Configuration options
#}

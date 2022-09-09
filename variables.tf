#variable "AWS_ACCESS_KEY" {}
#variable "AWS_SECRET_KEY" {}

variable "region" {
  default = "us-west-2"
}

variable "environment" {
  description = "Deployment Environment"
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
  default     = "10.200.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
  default     = ["10.200.0.0/18", "10.200.64.0/18"]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Private Subnet"
  default     = ["10.200.128.0/18", "10.200.192.0/18"]
}

variable "default_internet_cidr" {
  type        = list(any)
  description = "default CIDR block for internet"
  default     = ["0.0.0.0/0"]
}

variable "ami" {
  type        = string
  description = "AMI to be used for EC2"
  default     = "ami-07d59d159373b8030"
}

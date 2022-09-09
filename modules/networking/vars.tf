variable "environment" {
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Private Subnet"
}

variable "default_internet_cidr" {
  type        = list(any)
  description = "default CIDR block for internet"
}

variable "availability_zones" {
  type        = list(any)
  description = "AZ in which the resources will be deployed"
}
variable "region" {
  type        = string
  description = "AWS Region where the resources will deployed"
  default     = "us-west-2"
}

variable "ami" {
  type        = string
  description = "AMI to be used for EC2"
}

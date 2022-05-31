#General Data
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "region" {
  description = "The AWS region"
  default     = "us-east-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ports" {
  default = ["80", "8080", "22"]
}

variable "key_name" {
  default = "Ohio1"
}

data "aws_ami" "ubuntu" {
  owners           = ["099720109477"]
  most_recent      = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

variable "EC2_sg" {
  default     = "EC2_sg security group"
}

#Variables for Network
variable "cidr_block" {
  description = "The CIDR block of network"
  default     = "10.0.0.0/16"
}

variable "aws_dns" {
  type    = bool
  default = true
}

locals {
  number_public_subnets  = 2
  number_private_subnets = 2
  azs                    = data.aws_availability_zones.available.names
  number_bastion_servers = 2
  number_web_servers     = 2
}

#Variables for Application Load Balancer
variable "app_port" {
  description = "The application port"
  default     = 80
}

variable "app_target_port" {
  description = "The application port"
  default     = 8080
}

variable "health_check_path" {
  description = "The path for health check web servers"
  default     = "/"
}
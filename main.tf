variable "region" {
  description = "The AWS region for the project"
  default     = "us-east-2"
}
provider "aws" {
  region = var.region
}

module "network" {
  source = "./vpc"

  cidr_block        = "10.10.0.0/16"
  aws_dns           = true
  app_port          = 80
  app_target_port   = 8080
  health_check_path = "/"
}
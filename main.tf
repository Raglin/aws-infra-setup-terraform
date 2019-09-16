provider "aws" {
  shared_credentials_file = "~/.aws/creds"
  region     = "eu-west-1"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = "${module.vpc.vpc_id}"
}

module "vpc" {
  source ="terraform-aws-modules/vpc/aws"

  name = "sample-vpc"

  cidr = "10.10.0.0/16"

  azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets      = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Owner       = "raglin"
    Environment = "development"
  }
}

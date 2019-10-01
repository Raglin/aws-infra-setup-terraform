# aws-infra-setup-terraform
basic vpc setup with bastion

Terraform relies on AWS CLI setup for credentials.

to use

1. terraform-state/terraform init, terraform apply
2. vpc/terraform init, terraform apply
...and so on

VPC setup as follows:

CDIR 10.10.0.0/16

azs ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

3 private subnets, 1 per az
3 public subnets, 1 per az

Single nat gateway

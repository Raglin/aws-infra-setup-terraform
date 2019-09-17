terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-state-ebironconcot"
    key            = "global/bastion/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
      bucket         = "terraform-state-ebironconcot"
      key            = "global/vpc/terraform.tfstate"
      region         = "eu-west-1"
    }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-2.0.*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

provider "aws" {
  region     = "eu-west-1"
}


resource "aws_security_group" "bastion_sg" {
  name = "johndoe-sg"

  description = "Bastion-SG"
  
  vpc_id = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
}

resource "aws_security_group_rule" "bastion_ingress_access" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.bastion_sg.id}"
}

resource "aws_security_group_rule" "bastion_egress_access" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.bastion_sg.id}"
}

resource "aws_instance" "bastion" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.bastion_sg.id}" ]
  associate_public_ip_address = true
  
  ami = "${data.aws_ami.amazon_linux.id}"
  availability_zone = "eu-west-1a"
  key_name = "raglin-personal-aws"
 
  subnet_id = "${data.terraform_remote_state.vpc.outputs.public_subnets[0]}"
}

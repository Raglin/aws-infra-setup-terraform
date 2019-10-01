terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-state-ebironconcot"
    key            = "global/servers/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

provider "aws" {
  region     = "eu-west-1"
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
      bucket         = "terraform-state-ebironconcot"
      key            = "global/vpc/terraform.tfstate"
      region         = "eu-west-1"
    }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*",
    ]
  }
}

resource "aws_security_group" "ubuntu_sg" {
  name = "ubuntu_sg"

  description = "Ubuntu security group"
  
  vpc_id = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
}

resource "aws_security_group_rule" "ubuntu_ingress_access" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.ubuntu_sg.id}"
}

resource "aws_security_group_rule" "ubuntu_egress_access" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.ubuntu_sg.id}"
}

resource "aws_instance" "ubuntu_server" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.ubuntu_sg.id}" ]
  associate_public_ip_address = false
  
  ami = "${data.aws_ami.ubuntu.id}"
  #availability_zone = "eu-west-1a"
  key_name = "raglin-personal-aws"
 
  subnet_id = "${data.terraform_remote_state.vpc.outputs.private_subnets[0]}"

  tags = {
    Name = "bloomreach-poc"
  }
}

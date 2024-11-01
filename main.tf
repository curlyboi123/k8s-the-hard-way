locals {
  region        = "eu-west-1"
  key_pair_name = "accenture-laptop"
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Project = "github.com/curlyboi123/k8s-the-hard-way"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.14.0"

  name = "k8s-hard-way-vpc"
  cidr = "10.0.0.0/27"

  azs            = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = ["10.0.0.0/28"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

resource "aws_security_group" "main" {
  name        = "k8s-the-hard-way-sg"
  description = "Control traffic to k8s instances"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["debian-12-arm64-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_instance" "jumpbox" {
  ami = data.aws_ami.debian.id

  instance_type = "t3.nano"

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  key_name = local.key_pair_name

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "jumpbox"
  }
}

resource "aws_instance" "server" {
  ami = data.aws_ami.debian.id

  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  key_name = local.key_pair_name

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "server"
  }
}

resource "aws_instance" "node" {
  count = 2

  ami = data.aws_ami.debian.id

  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  key_name = local.key_pair_name

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "node-${count.index}"
  }
}

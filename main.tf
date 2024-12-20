locals {
  region            = "eu-west-1"
  key_pair_name     = "personal-pc-wsl"
  allow_ssh_with_kp = false
  my_ipv4           = "${chomp(data.http.my_ipv4.response_body)}/32"

  jumpbox_instance_type     = "t4g.nano"
  jumpox_root_vol_size      = 10
  server_node_instance_type = "t4g.small"
  server_node_root_vol_size = 20
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Project = "https://github.com/curlyboi123/k8s-the-hard-way"
    }
  }
}

data "http" "my_ipv4" {
  url = "https://ipv4.icanhazip.com"
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

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_from_my_ip" {
  count = local.allow_ssh_with_kp ? 1 : 0

  security_group_id = aws_security_group.main.id
  cidr_ipv4         = local.my_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_internal_tcp_ingress" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = module.vpc.public_subnets_cidr_blocks[0]
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_all_internal_tcp_egress" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = module.vpc.public_subnets_cidr_blocks[0]
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

data "aws_ami" "debian_arm64" {
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

data "cloudinit_config" "jumpbox" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "_00_install_ssm_agent.sh"
    content_type = "text/x-shellscript"

    content = file("${path.module}/scripts/_00_install_ssm_agent.sh")
  }

  part {
    filename     = "00_add_machines_file"
    content_type = "text/cloud-config"

    content = yamlencode(
      {
        "write_files" : [
          {
            "path" : "/tmp/machines.txt"
            "content" : templatefile("${path.module}/templates/machines.tftpl",
              {
                server_ip = aws_instance.server.private_ip,
                node_0_ip = aws_instance.node[0].private_ip
                node_1_ip = aws_instance.node[1].private_ip
            })
          }
        ]
      }
    )
  }

  dynamic "part" {
    for_each = fileset("${path.module}/scripts/k8s_setup", "*")
    content {
      filename     = part.value
      content_type = "text/x-shellscript"
      content      = file("scripts/k8s_setup/${part.value}")
    }
  }
}

resource "aws_instance" "jumpbox" {
  ami = data.aws_ami.debian_arm64.id

  instance_type = local.jumpbox_instance_type

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  key_name = local.allow_ssh_with_kp ? local.key_pair_name : null

  user_data                   = data.cloudinit_config.jumpbox.rendered
  user_data_replace_on_change = true

  iam_instance_profile = aws_iam_instance_profile.k8s_instances.name

  root_block_device {
    volume_size = local.jumpox_root_vol_size
  }

  tags = {
    Name = "jumpbox"
  }
}

resource "aws_instance" "server" {
  ami = data.aws_ami.debian_arm64.id

  instance_type = local.server_node_instance_type

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  key_name = local.allow_ssh_with_kp ? local.key_pair_name : null

  user_data                   = file("${path.module}/scripts/k8s_setup/01_allow_root_ssh.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size = local.server_node_root_vol_size
  }

  tags = {
    Name = "server"
  }
}

resource "aws_instance" "node" {
  count = 2

  ami = data.aws_ami.debian_arm64.id

  instance_type = local.server_node_instance_type

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  key_name = local.allow_ssh_with_kp ? local.key_pair_name : null

  user_data                   = file("${path.module}/scripts/k8s_setup/01_allow_root_ssh.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size = local.server_node_root_vol_size
  }

  tags = {
    Name = "node-${count.index}"
  }
}

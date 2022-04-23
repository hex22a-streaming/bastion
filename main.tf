terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
  default_tags {
      tags = {
          Source = "Terraform"
      }
  }
}

resource "aws_vpc" "secure_cloud" {
    cidr_block = "11.0.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.secure_cloud.id
    cidr_block = "11.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_security_group" "bitwarden_sg" {
  vpc_id = aws_vpc.secure_cloud.id
  ingress {
    description = "TLS from everywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0f9fc25dd2506cf6d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bitwarden_sg.id]

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
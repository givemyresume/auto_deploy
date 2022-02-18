terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "example-org-bae840"

    workspaces {
      name = "resume-builder"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}


resource "aws_instance" "webserver" {
  ami           = "ami-0f2e255ec956ade7f"
  instance_type = "t2.micro"
  tags = {
    Name        = "webserver"
    Description = "Resume Builder Server"
  }
  key_name               = aws_key_pair.ssh-key.id
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  user_data              = file("./initiate_server.sh")
}

resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.webserver.id
  provisioner "local-exec" {
    command = "echo ${aws_eip.eip.public_dns} >> ./runtime_txts/webserver_public_dns.txt"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKCI6j1VpcMgYLIxnE05BqXJnm/gcPUluURx6mrorSp/BVfs8K7Sdhn5gD/PphxhYohcJ+zA+u7yweg7/SJ1KUL+oDypH5vtIRCav13lyNYIGNvxevXAOwb6Yy7jYX5Qd4ZHCAF6c/9upx1ewCBj49W74CKvIwjEws3YRpk/cW9pmRxJ0nQq0dDlArqc734L8XkRpoSuwdKy65Zy0LViPRgYfwXezt/vS4XSGkFdYsN4aMjBAfAxESy4/b1oOcBbEptiJDBQugJjYPEAKXW8SVLtM+0Zw8TDJrWnd8ruzFuoP7lHIUOq/CNWDrrzzlmsU7noQfxGhwDhE5EuNc5ZW5 subhayu@FFT-ThinkPad-L490"
}

resource "aws_security_group" "server_sg" {
  name        = "server_sg"
  description = "Allow SSH, HTTP and HTTPS access from the Internet"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ebs_volume" "storage_volume" {
  availability_zone = aws_instance.webserver.availability_zone
  size              = 10
  tags = {
    Name = "instance storage"
  }
}

resource "aws_volume_attachment" "ec2_attach" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.webserver.id
  volume_id   = aws_ebs_volume.storage_volume.id
}

output "eip_dns" {
  value = aws_eip.eip.public_dns
}

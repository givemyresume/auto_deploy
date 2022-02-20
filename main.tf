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
  key_name               = "server-key"
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  user_data              = file("./initiate_server.sh")
  connection {
    type = "ssh"
    user = "appuser"
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "export FAUNA_DB_KEY=${var.FAUNA_DB_KEY}",
      "export GITHUB_TOKEN=${var.GITHUB_TOKEN}",
      "export API_URL=${var.API_URL}",
      "cd /website",
      "nohup python3 manage.py runserver 8000 &",
      "cd /api",
      "nohup uvicorn main:app --reload --port 8001 &"
    ]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = aws_instance.webserver.id
  allocation_id = "eipalloc-085afc5d8993450ac"
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
  size              = 5
  tags = {
    Name = "instance storage"
  }
}

resource "aws_volume_attachment" "ec2_attach" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.webserver.id
  volume_id   = aws_ebs_volume.storage_volume.id
}


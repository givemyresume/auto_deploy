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


variable "FAUNA_DB_KEY" {
  type = string
}

variable "GITHUB_TOKEN" {
  type = string
}

variable "API_URL" {
  type = string
}

variable "SSH_PUB_KEY" {
  type = string
}

variable "EMAIL_PASS" {
  type = string
}


resource "tls_private_key" "terraform-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated-key" {
  key_name   = "generated-key"       # Create "generated-key" to AWS!!
  public_key = tls_private_key.terraform-key.public_key_openssh

  provisioner "local-exec" { # Create "generated-key.pem" to your computer!!
    command = "echo '${tls_private_key.terraform-key.private_key_pem}' > ./server-key.pem; chmod 400 server-key.pem"
  }
}


resource "aws_instance" "webserver" {
  ami           = "ami-0b8959ac764ad4343"
  instance_type = "t3.micro"
  tags = {
    Name        = "webserver"
    Description = "Resume Builder Server"
  }
  key_name               = aws_key_pair.generated-key.key_name
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = tls_private_key.terraform-key.private_key_pem
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "echo ${var.SSH_PUB_KEY} >> /home/ubuntu/.ssh/authorized_keys && chown ubuntu: /home/ubuntu/.ssh/authorized_keys && chmod 0600 /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-get -y remove docker docker-engine docker.io containerd runc",
      "sudo apt-get -y update && sudo apt-get -y install apt-transport-https software-properties-common git ca-certificates curl gnupg lsb-release && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable' && sudo apt-get -y update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io && sudo service docker start && sudo apt-get -y update && sudo apt install docker-compose -y",
      "sudo apt update && sudo apt install nginx -y",
      "git clone https://github.com/givemyresume/auto_deploy.git",
      "cd /home/ubuntu/auto_deploy",
      "git clone https://github.com/givemyresume/api.git && chmod 777 api -R",
      "git clone https://github.com/givemyresume/website.git && chmod 777 website -R",
      "cd /home/ubuntu/auto_deploy/api && git clone https://github.com/givemyresume/givemyresume.github.io.git && chmod 777 givemyresume.github.io -R && cd -",
      "sudo cp /home/ubuntu/auto_deploy/server.conf /etc/nginx/conf.d",
      "sudo unlink /etc/nginx/sites-enabled/default",
      "sudo service nginx restart",
      "echo 'FAUNA_DB_KEY=${var.FAUNA_DB_KEY}\nGITHUB_TOKEN=${var.GITHUB_TOKEN}\nAPI_URL=${var.API_URL}\nEMAIL_PASS=${var.EMAIL_PASS}' > .env",
      "echo '${var.EMAIL_PASS}' > /home/ubuntu/auto_deploy/api/cred.txt && chmod 777 /home/ubuntu/auto_deploy/api/cred.txt",
      "sudo docker-compose up -d | tee /home/ubuntu/logs/dc_up.log",
      "sudo apt -y update && sudo apt install certbot python3-certbot-nginx -y",
      "at now +5 minutes -f /home/ubuntu/auto_deploy/run_later.sh && atq && at -c $(atq | grep '^[0-9]*' -o | head -n 1)"
    ]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.webserver.id
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
  ingress {
    from_port   = 8001
    to_port     = 8001
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

output "webserver_public_ip" {
  value = aws_instance.webserver.public_ip
}

output "webserver_public_dns" {
  value = aws_instance.webserver.public_dns
}

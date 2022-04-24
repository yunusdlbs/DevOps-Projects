terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.11.0"
    }
    github = {
      source = "integrations/github"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Configuration options
}

provider "github" {
  token = "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" # Configuration options
}

resource "github_repository" "bookstore" {
  name = "Bookstore-API"
  auto_init = true 
  visibility = "private"
}

resource "github_branch_default" "name" {
  branch = "main" 
  repository = github_repository.bookstore.name
}

variable "files" {
  default = ["bookstore-api.py", "docker-compose.yml", "Dockerfile", "requirements.txt"]
}

resource "github_repository_file" "app-files" {
  for_each = toset(var.files)
  content = file(each.value)
  file = each.value
  repository = github_repository.bookstore.name
  branch = "main"
  commit_message = "managed by terraform"
  overwrite_on_create = true
}

resource "aws_security_group" "tf-docker-sec-gr-203" {
  name = "docker-sec-gr"
  tags = {
    "Name" = "docker-sec-gr"
  }
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "name" {
  ami = "ami-0f9fc25dd2506cf6d"
  instance_type = "t2.micro"
  key_name = "firstkey"
  security_groups = ["docker-sec-gr"]
  tags = {
    "Name" = "Webserver os Bookstore"
  }
  user_data = <<-EOF
          #! /bin/bash
          yum update -y
          amazon-linux-extras install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
          -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          mkdir -p /home/ec2-user/bookstore-api
          TOKEN="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"
          FOLDER="https://$TOKEN@raw.githubusercontent.com/yunusdlbs/Bookstore-API/main/"
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/bookstore-api.py" -L "$FOLDER"bookstore-api.py
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/requirements.txt" -L "$FOLDER"requirements.txt
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/Dockerfile" -L "$FOLDER"Dockerfile
          curl -s --create-dirs -o "/home/ec2-user/bookstore-api/docker-compose.yml" -L "$FOLDER"docker-compose.yml
          cd /home/ec2-user/bookstore-api
          docker build -t yunusdelibas/bookstore-api:1.0 .
          docker-compose up -d
          EOF
  depends_on = [
    github_repository_file.app-files, github_repository.bookstore
  ]
}

output "website" {
  value = "http://${aws_instance.name.public_dns}"
}
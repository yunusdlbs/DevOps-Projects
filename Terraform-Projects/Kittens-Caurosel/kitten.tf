provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}


resource "aws_instance" "kitten" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  key_name               = "firstkey"
  vpc_security_group_ids = [aws_security_group.my-sec.id]
  user_data              = file("./kitten.sh")
  tags = {
    Name = "kitten-terraform"
  }

}

resource "aws_security_group" "my-sec" {
  name        = "my-sec"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTP-SHH-Terraform"
  }
}

output "kitten_link" {
  value = "http://${aws_instance.kitten.public_ip}"
}
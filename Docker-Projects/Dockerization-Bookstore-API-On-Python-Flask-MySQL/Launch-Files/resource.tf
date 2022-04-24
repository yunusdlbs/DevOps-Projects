resource "aws_security_group" "EC2-SecurityGroup" {
  name = "EC2-SecurityGroup"
  description = "Allows SSH and HTTP connection"
  vpc_id = data.aws_vpc.main_vpc.id
  ingress {
      to_port = 22
      from_port = 22
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
  }
   ingress {
      to_port = 80
      from_port = 80
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
      to_port = 0
      from_port = 0
      protocol = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]  
  }
}

resource "aws_instance" "Docker-Bookstore" {
  ami = data.aws_ami.last_ami.id
  key_name = "firstkey"
  security_groups = ["EC2-SecurityGroup"]
  instance_type = "t2.micro"
  user_data = file("./user_data.sh")
tags = {
  "Name" = "Web Server of Bookstore"
}
}


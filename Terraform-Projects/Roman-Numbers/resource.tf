resource "aws_security_group" "my-sec" {
  name = "Web Security Group"
  description = "Allows SHH and HTTP connection"
  vpc_id = var.vpc_id

  ingress {
    to_port = 80
    from_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
      to_port = 22
      from_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  
}

data "aws_ami" "tf_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "roman_instance" {
  ami = data.aws_ami.tf_ami.id
  instance_type = "t2.micro"
  key_name = var.key-name
  security_groups = [ "Web Security Group" ]
  user_data = file("./configuration.sh")
  tags = {
    "Name" = "Roman Numerals"
  }
}
data "aws_ami" "last_ami" {
  owners = [ "amazon" ]
  most_recent = true
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm*" ]
  }
   filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "aws_vpc" "main_vpc" {
  default = true
}
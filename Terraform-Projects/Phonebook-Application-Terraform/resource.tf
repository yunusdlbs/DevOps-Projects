resource "aws_security_group" "ec2SecGrp" {
  name        = "WebServerSG"
  description = "Allow SSH and HTTP only from ALB"
  vpc_id      = data.aws_vpc.main_vpc.id
  // To Allow SSH Transport
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport from ALB
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    security_groups = [ aws_security_group.ALBSG.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ALBSG" {
  name        = "ALBSG"
  description = "Allow  HTTP only from ALB"
  vpc_id      = data.aws_vpc.main_vpc.id


  // To Allow Port 80 Transport from ALB
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "RDSSG" {
  name = "RDS_SecurityGroup"
  description = "Allow 3306 traffic"

  ingress {
      to_port = 3306
      from_port = 3306
      security_groups = [aws_security_group.ec2SecGrp.id]
      protocol = "tcp"
  }
  egress {
      to_port = 0
      from_port = 0
      cidr_blocks = ["0.0.0.0/0"]
      protocol = "-1"  
  }
}

# resource "aws_db_security_group" "RDSSG" {
#   name = "rds_sg"

#   ingress {
#    security_group_name = aws_security_group.ec2SecGrp.name
#   }

#   depends_on = [
#     aws_security_group.ec2SecGrp
#   ]
# }


resource "aws_launch_template" "PhoneBookLT" {
  name                   = "WebServerLaunchTemplate"
  image_id               = data.aws_ami.tf_ami.id
  instance_type          = lookup(var.awsprops, "instancetype")
  key_name               = lookup(var.awsprops, "keyname")
  vpc_security_group_ids = [aws_security_group.ec2SecGrp.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "Terraform Launch Template"
    }
  }
  # user_data = filebase64("./romannumbers.sh")
  user_data = "${base64encode(templatefile("./post_configuration.tftpl", {rds_endpoint = "${aws_db_instance.mySQLRDS.address}"}))}"
}

resource "aws_lb_target_group" "rTG" {
  name        = "tf-phonebook-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main_vpc.id
  target_type = "instance"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

}

resource "aws_autoscaling_group" "rASG" {
  launch_template {
    id      = aws_launch_template.PhoneBookLT.id
    version = "$Latest"
  }
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  max_size                  = 3
  min_size                  = 1
  target_group_arns         = [aws_lb_target_group.rTG.arn]
  vpc_zone_identifier = ["subnet-0d5f07abc987b4e1f", "subnet-07f44de775248ab45"]
}

resource "aws_lb" "rLoadBalancer" {
  name                       = "test-lb-tf"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.ALBSG.id}"]
  subnets                    = ["subnet-0d5f07abc987b4e1f", "subnet-07f44de775248ab45"]
  enable_deletion_protection = false

  tags = {
    Environment = "test"
  }
}

resource "aws_lb_listener" "rALBListener" {
  load_balancer_arn = aws_lb.rLoadBalancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rTG.arn
  }
}

resource "aws_db_instance" "mySQLRDS" {
  identifier                  = "clarusway"
  instance_class              = "db.t2.micro"
  allocated_storage           = 20
  engine                      = "mysql"
  engine_version              = "8.0.25"
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  username                    = lookup(var.dbprops, "username")
  password                    = var.db_password
  vpc_security_group_ids      = [aws_security_group.RDSSG.id]
  publicly_accessible         = true
  skip_final_snapshot         = true
  db_name                     = "clarusway_phonebook"
  tags = {
    "Name" = "Dev"
  }
}




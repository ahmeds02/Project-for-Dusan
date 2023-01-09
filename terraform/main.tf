terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  shared_credentials_file = "C:\Users\ahmed\.aws\credentials"
  region  = var.region
}

resource "aws_route_53" "exampleDomain" {
  name = var.domainName
}

resource "aws_route53_record" "exampleDomain-a" {
  zone_id = aws_route53_zone.exampleDomain.zone_id
  name    = var.record_name
  type    = "A"
  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}

# CREATE VPC 

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = "AWSS-vpc"
  }
}


# create Internet Gateway


resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "AWSS-internet-gateway"
  }
}

# ADD ROUTE TABLE TO IG 


resource "aws_route" "route" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gateway.id}"
}


# CREATE RDS PRIVATE SUBNET


resource "aws_subnet" "rds_subnet1" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[0]

  tags = {
    Name = "rds_private_subnet1"
  }
}


resource "aws_subnet" "rds_subnet2" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[3]

  tags = {
    Name = "rds_private_subnet2"
  }
}

resource "aws_subnet" "rds_subnet3" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[5]

  tags = {
    Name = "rds_private_subnet3"
  }
}


#CREATE SUBNET GROUP


resource "aws_db_subnet_group" "rds" {
  name       = "main"
  subnet_ids = ["${aws_subnet.rds_subnet1.id}", "${aws_subnet.rds_subnet2.id}", "${aws_subnet.rds_subnet3.id}"]

  tags = {
    Name = "AWSS-DB subnet group"
  }
  }

#CREATE RDS SECURITY GROUP

resource "aws_security_group" "rds" {
  name        = "mysqlallow"
  description = "ssh allow to the mysql"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description = "ssh"
    security_groups= ["${aws_security_group.web_sg1.id}", "${aws_security_group.web_sg2.id}", "${aws_security_group.web_sg3.id}"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    description = "MYSQL"
    security_groups= ["${aws_security_group.web_sg1.id}", "${aws_security_group.web_sg2.id}", "${aws_security_group.web_sg3.id}"]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG OF AWSS RDS"
  }
}



# CREATE RDS DB INSTANCE
resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.19"
  instance_class       = "db.m5.large"
  name                 = "${var.database_name}"
  username             = "${var.database_user}"
 password             = "${var.database_password}"
 db_subnet_group_name = "${aws_db_subnet_group.rds.id}"
   publicly_accessible = "false"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  skip_final_snapshot  = true


  tags = {
    Name = "AWSS-RDS-MYSQL"
  }
}


# CREATE  WEB SUBNET--PUBLIC

resource "aws_subnet" "web_subnet2" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[1]

  tags = {
    Name = "public-subnet2"
  }
}


resource "aws_subnet" "web_subnet3" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[2]

  tags = {
    Name = "public-subnet3"
  }
}

resource "aws_subnet" "web_subnet4" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[3]

  tags = {
    Name = "public-subnet4"
  }
}

#CREATE  WEB SUCURITY GROUP
resource "aws_security_group" "web_sg1" {
  name   = "SG for Instance"
  description = "Security group"
  vpc_id      = "${aws_vpc.vpc.id}"
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
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
    Name = "AWSS-WEB-security-group1"
  }
}

#CREATE WEB SUCURITY GROUP2
resource "aws_security_group" "web_sg2" {
  name   = "SG2 for Instance"
  description = "Security group"
  vpc_id      = "${aws_vpc.vpc.id}"
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
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
    Name = "AWSS-WEB-security-group2"
  }
}

resource "aws_security_group" "web_sg3" {
  name   = "SG3 for Instance"
  description = "Security group"
  vpc_id      = "${aws_vpc.vpc.id}"
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
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
    Name = "AWSS-WEB-security-group3"
  }
}

#CREATE EC2 INSTANCE
resource "aws_instance" "app_server" {
  ami                                  = var.amis[var.region] 
  instance_type                        = "m5.large"
  associate_public_ip_address          = true
  key_name                             = "AWSS"
  vpc_security_group_ids               = ["${aws_security_group.web_sg1.id}", "${aws_security_group.web_sg2.id}", "${aws_security_group.web_sg3.id}"]
  subnet_id                           = "${aws_subnet.web_subnet2.id}"
  instance_initiated_shutdown_behavior = "terminate"
  root_block_device {
    volume_type = "gp2"
    volume_size = "15"
  }


  tags = {
    Name = var.instance_name
  }

depends_on = [aws_db_instance.rds]
}


#CREATE EC2 IMAGE


resource "aws_ami_from_instance" "ec2_image" {
  name               = "ec2-image"
  source_instance_id = "${aws_instance.app_server.id}"

depends_on = [aws_instance.app_server]
}



# CREATE AUTO SCALING LAUNCH COINFIG 

resource "aws_launch_configuration" "ec2" {
  image_id               = "${aws_ami_from_instance.ec2_image.id}"
  instance_type          = "m5.large"
  key_name               = "AWSS"
  security_groups        =  ["${aws_security_group.web_sg1.id}", "${aws_security_group.web_sg2.id}", "${aws_security_group.web_sg3.id}"]
  lifecycle {
    create_before_destroy = true
  }
}



#AutoScaling Group

resource "aws_autoscaling_group" "ec2" {
  launch_configuration = "${aws_launch_configuration.ec2.id}"
  min_size = 2
  max_size = 3

  target_group_arns = ["${aws_alb_target_group.group.arn}"]
 vpc_zone_identifier  = ["${aws_subnet.web_subnet4.id}","${aws_subnet.web_subnet3.id}", "${aws_subnet.web_subnet2.id}"]
  health_check_type = "EC2"
}

#Security group Application load balancer 

resource "aws_security_group" "alb" {
  name        = "Alb_security_group"
  description = "Load balancer security group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }
 # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name = "AWSS-alb-security-group"
  }
}



# CREATE ALB 


resource "aws_alb" "alb" {
  name            = "Alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.web_subnet2.id}","${aws_subnet.web_subnet3.id}","${aws_subnet.web_subnet4.id}"]
  tags = {
    Name = "AWSS-alb"
  }
}


# New target group

resource "aws_alb_target_group" "group" {
  name     = "Alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
  stickiness {
    type = "lb_cookie"
  }
}



#  ALB  listerners


resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}

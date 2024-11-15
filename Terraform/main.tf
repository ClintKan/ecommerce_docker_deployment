#Creating of a VPC
resource "aws_vpc" "wl6vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {

    "Name" : "wl6vpc"
  }
}

#Creating the elastic IP in AZ 1a
resource "aws_eip" "elastic_ip_1a" {
  #instance = aws_nat_gateway.wl6vpc_ngw_1a.id
  domain = "vpc"
  tags = {
    "Name" : "wl6vpc_eip_1a"
  }
}

#Creating the elastic IP in AZ 1b
resource "aws_eip" "elastic_ip_1b" {
  #instance = aws_nat_gateway.wl6vpc_ngw_1b.id
  domain = "vpc"
  tags = {
    "Name" : "wl6vpc_eip_1b"
  }
}



resource "aws_vpc_peering_connection" "Peering_wl5_default" {
  # peer_owner_id = var.peer_owner_id
  peer_vpc_id = aws_vpc.wl6vpc.id       #ID of the target VPC
  vpc_id      = "vpc-078d543d16826cfcd" #ID of the VPC requesting
  auto_accept = true

  accepter { # using this block because vpc wl5vpc is the one accepting
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "VPC Peering between wl6vpc and Default"
  }
}


resource "aws_lb" "wl6-lb" {
  name               = "wl6-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wl6_lb_sg.id]
  subnets            = [aws_subnet.pub_subnet_1a.id, aws_subnet.pub_subnet_1b.id]
}

resource "aws_lb_target_group" "wl6_lb_tg" {
  name     = "wl6-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.wl6vpc.id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "alb_1" {
  target_group_arn = aws_lb_target_group.wl6_lb_tg.arn
  target_id        = aws_instance.ecommerce_app_az1.id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "alb_2" {
  target_group_arn = aws_lb_target_group.wl6_lb_tg.arn
  target_id        = aws_instance.ecommerce_app_az2.id
  port             = 3000
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.wl6-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wl6_lb_tg.arn
  }
}



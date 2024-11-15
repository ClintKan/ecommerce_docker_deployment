# Public Security Group "pub_secgrp" that allows SSH, HTTP, HTTPS & Grafana traffic.
resource "aws_security_group" "pub_secgrp" {
  name        = "pub_secgrp"
  description = "sec grp for pub subnet"
  vpc_id      = aws_vpc.wl6vpc.id

  # Ingress rules:
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #172.31.0.0/16
  }
  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  # Egress is the traffic coming out of the infra
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to any IP address
  }

  # Tags for the security group
  tags = {
    "Name" : "pub_secgrp" # Name tag for the security group
    "Terraform" : "true"  # Custom tag to indicate this SG was created with Terraform
  }
}


####------

# Load Balancer Security Group "Load Balancer".
resource "aws_security_group" "wl6_lb_sg" {
  name        = "wl6_lb_sg"
  description = "sec grp for load balancer"
  vpc_id      = aws_vpc.wl6vpc.id

  # Ingress rules:
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress is the traffic coming out of the infra
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to any IP address
  }

  # Tags for the security group
  tags = {
    "Name" : "wl6_lb_sg" # Name tag for the security group
  }
}

####------

# Private Security Group "priv_secgrp" that allows SSH & Django traffic.
resource "aws_security_group" "priv_secgrp" {
  name        = "priv_secgrp"
  description = "sec grp for priv subnet"
  vpc_id      = aws_vpc.wl6vpc.id

  # Ingress rules:
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #10.0.0.0/25
  }

  ingress {
    description = "Django"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "React"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/25"]
  }
  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20"]
  }

  # Egress is the traffic coming out of the infra
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"] # 10.0.0.0/25 # Allow traffic to the specific IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"              # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"] # 172.31.0.0/20 # Allow traffic to the specific IP address
  }
  # Tags for the security group
  tags = {
    "Name" : "priv_secgrp" # Name tag for the security group
    "Terraform" : "true"   # Custom tag to indicate this SG was created with Terraform
  }
}

# Private Security Group "priv_rds_secgrp" that allows SSH & Django traffic.
resource "aws_security_group" "priv_rds_secgrp" {
  name        = "priv_rds_secgrp"
  description = "sec grp for priv subnet"
  vpc_id      = aws_vpc.wl6vpc.id

  # Ingress rules:
  ingress {
    description = "RDS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.128/26"]
  }

  # Egress is the traffic coming out of the infra
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"              # "-1" means all protocols
    cidr_blocks = ["10.0.0.128/26"] # Allow traffic to any IP address
  }

  # Tags for the security group
  tags = {
    "Name" : "priv_rds_secgrp" # Name tag for the security group
    "Terraform" : "true"       # Custom tag to indicate this SG was created with Terraform
  }
}

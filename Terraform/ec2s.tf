# Creating of the EC2 Instance for the web server in AZ - us-east-1a, in the pub subnet
resource "aws_instance" "ecommerce_bastion_az1" {
  ami           = "ami-0866a3c8686eaeeba" # AMI ID of Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  instance_type = var.instance_type       # Specify the desired EC2 instance size.

  # Security groups control the inbound and outbound traffic to WebSrv EC2 instance.
  vpc_security_group_ids = [aws_security_group.pub_secgrp.id] #
  key_name               = "Clint-Instance"                         # The key pair name for the workload
  subnet_id              = aws_subnet.pub_subnet_1a.id # associating a subnet to be tied to this EC2

  tags = {
    "Name" : "ecommerce_bastion_az1"
  }

}

# Creating of the EC2 Instance for the web server in AZ - us-east-1b, in the pub subnet
resource "aws_instance" "ecommerce_bastion_az2" {
  ami           = "ami-0866a3c8686eaeeba" # AMI ID of Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  instance_type = var.instance_type       # Specify the desired EC2 instance size.

  # Security groups control the inbound and outbound traffic to WebSrv EC2 instance.
  vpc_security_group_ids = [aws_security_group.pub_secgrp.id] #
  key_name               = "Clint-Instance"                         # The key pair name for the workload
  subnet_id              = aws_subnet.pub_subnet_1b.id # associating a subnet to be tied to this EC2

  tags = {
    "Name" : "ecommerce_bastion_az2"
  }

}

#######################------------------------------------------------------------------------------------------------------------


# Creating of the EC2 Instance for the App server in AZ - us-east-1a, in the priv subnet
resource "aws_instance" "ecommerce_app_az1" {
  ami           = "ami-0866a3c8686eaeeba" # AMI ID of Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  instance_type = var.instance_type       # Specify the desired EC2 instance size.

  # Security groups control the inbound and outbound traffic to WebSrv EC2 instance.
  vpc_security_group_ids = [aws_security_group.priv_secgrp.id] #
  key_name               = "Clint-Instance"                          # The key pair name for the workload
  user_data              = base64encode(templatefile("${path.module}/deploy.sh", {
    rds_endpoint = aws_db_instance.main.endpoint,
    docker_user = var.dockerhub_username,
    docker_pass = var.dockerhub_password,
    docker_compose = templatefile("${path.module}/compose.yaml", {
      rds_endpoint = aws_db_instance.main.endpoint
    })
  }))
  subnet_id              = aws_subnet.priv_subnet_1a.id # associating a subnet to be tied to this EC2

  tags = {
    "Name" : "ecommerce_app_az1"
  }

  depends_on = [aws_db_instance.main, aws_nat_gateway.main]

}

# Creating of the EC2 Instance for the App server in AZ - us-east-1b, in the priv subnet
resource "aws_instance" "ecommerce_app_az2" {
  ami           = "ami-0866a3c8686eaeeba" # AMI ID of Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  instance_type = var.instance_type       # Specify the desired EC2 instance size.

  # Security groups control the inbound and outbound traffic to WebSrv EC2 instance.
  vpc_security_group_ids = [aws_security_group.priv_secgrp.id] #
  key_name               = "Clint-Instance"                          # The key pair name for the workload
  subnet_id              = aws_subnet.priv_subnet_1b.id   # associating a subnet to be tied to this EC2
  user_data              = base64encode(templatefile("${path.module}/deploy.sh", 
  {
    rds_endpoint = aws_db_instance.main.endpoint,
    docker_user = var.dockerhub_username,
    docker_pass = var.dockerhub_password,
    docker_compose = templatefile("${path.module}/compose.yaml",
     {
      rds_endpoint = aws_db_instance.main.endpoint
     })
  }))

  tags = {
    "Name" : "ecommerce_app_az2"
  }

  depends_on = [aws_db_instance.main, aws_nat_gateway.main]

}

#######################------------------------------------------------------------------------------------------------------------



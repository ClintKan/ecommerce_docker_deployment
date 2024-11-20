#Creating the internet gateway
resource "aws_internet_gateway" "wl6vpc_igw" {
  vpc_id = aws_vpc.wl6vpc.id

  tags = {
    "Name" : "wl6vpc_igw"
  }
}

#Creating a public route table 1a
resource "aws_route_table" "pub1a_rttable" {
  vpc_id = aws_vpc.wl6vpc.id

  route {
    cidr_block = "0.0.0.0/0" # this is traffic going out
    gateway_id = aws_internet_gateway.wl6vpc_igw.id
  }
  tags = {
    "Name" : "pub1a_rttable"
  }
}

#Creating a public route table 1b
resource "aws_route_table" "pub1b_rttable" {
  vpc_id     = aws_vpc.wl6vpc.id
  depends_on = [aws_vpc.wl6vpc, aws_nat_gateway.wl6vpc_ngw_1b]

  route {
    cidr_block = "0.0.0.0/0" # this is traffic going out
    gateway_id = aws_internet_gateway.wl6vpc_igw.id
  }
  tags = {
    "Name" : "pub1b_rttable"
  }
}


#Creating public_subnet 1a
resource "aws_subnet" "pub_subnet_1a" {
  vpc_id                  = aws_vpc.wl6vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" : "pub_subnet_1a"
  }

}

#Creating public_subnet 1b
resource "aws_subnet" "pub_subnet_1b" {
  vpc_id                  = aws_vpc.wl6vpc.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" : "pub_subnet_1b"
  }

}


#Creating an associ.. btn pub_subnet and pub rttble - for 1a
resource "aws_route_table_association" "pub1a" {
  subnet_id      = aws_subnet.pub_subnet_1a.id
  route_table_id = aws_route_table.pub1a_rttable.id
  depends_on     = [aws_subnet.pub_subnet_1a, aws_route_table.pub1a_rttable]
}

#Creating an associ.. btn pub_subnet and pub rttble - for 1b
resource "aws_route_table_association" "pub1b" {
  subnet_id      = aws_subnet.pub_subnet_1b.id
  route_table_id = aws_route_table.pub1b_rttable.id
  depends_on     = [aws_subnet.pub_subnet_1b, aws_route_table.pub1b_rttable]
}


######--------------------------


#Creating a Private Route Table 1a
resource "aws_route_table" "priv1a_rttable" {
  vpc_id = aws_vpc.wl6vpc.id

  route {
    cidr_block = "0.0.0.0/0" # 10.0.0.0/26" # this is destination the traffic should get to
    gateway_id = aws_nat_gateway.wl6vpc_ngw_1a.id
  }
  tags = {
    "Name" : "priv1a_rttable"
  }

}

#Creating a Private Route Table 1b
resource "aws_route_table" "priv1b_rttable" {
  vpc_id = aws_vpc.wl6vpc.id

  route {
    cidr_block = "0.0.0.0/0" # 10.0.0.64/26 # this is destination the traffic should get to
    gateway_id = aws_nat_gateway.wl6vpc_ngw_1b.id
  }
  tags = {
    "Name" : "priv1b_rttable"
  }

}

#Creating the private_subnet 1a
resource "aws_subnet" "priv_subnet_1a" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.128/27"
  availability_zone = "us-east-1a"
  tags = {
    "Name" : "priv_subnet_1a"
  }

}

#Creating the private_subnet 1b
resource "aws_subnet" "priv_subnet_1b" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.160/27"
  availability_zone = "us-east-1b"
  tags = {
    "Name" : "priv_subnet_1b"
  }

}


#Creating an associ.. btn priv_subnet and priv rttble - for 1a
resource "aws_route_table_association" "priv1a" {
  subnet_id      = aws_subnet.priv_subnet_1a.id
  route_table_id = aws_route_table.priv1a_rttable.id
}

#Creating an associ.. btn priv_subnet and priv rttble - for 1b
resource "aws_route_table_association" "priv1b" {
  subnet_id      = aws_subnet.priv_subnet_1b.id
  route_table_id = aws_route_table.priv1b_rttable.id
}


######------------------

#Creating the RDS private_subnet 1a
resource "aws_subnet" "rds_subnet_1a" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.192/27"
  availability_zone = "us-east-1a"
  tags = {
    "Name" : "rds_subnet_1a"
  }

}

#Creating the RDS private_subnet 1b
resource "aws_subnet" "rds_subnet_1b" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.224/27"
  availability_zone = "us-east-1b"
  tags = {
    "Name" : "rds_subnet_1b"
  }

}

#Creating the RDS Subnet Groups
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.rds_subnet_1a.id, aws_subnet.rds_subnet_1b.id]

  tags = {
    Name = "RDS subnet group"
  }
}


###########--------------------------------------------------------------------------------------



#Creating the nat gateway in AZ 1a
resource "aws_nat_gateway" "wl6vpc_ngw_1a" {
  allocation_id = aws_eip.elastic_ip_1a.id
  subnet_id     = aws_subnet.pub_subnet_1a.id
  depends_on    = [aws_internet_gateway.wl6vpc_igw] # critical to have this for systematic creation of resources

  tags = {
    "Name" : "wl6vpc_ngw_1a"
  }

}

#Creating the nat gateway in AZ 1b
resource "aws_nat_gateway" "wl6vpc_ngw_1b" {
  allocation_id = aws_eip.elastic_ip_1b.id
  subnet_id     = aws_subnet.pub_subnet_1b.id
  depends_on    = [aws_internet_gateway.wl6vpc_igw] # critical to have this for systematic creation of resources

  tags = {
    "Name" : "wl6vpc_ngw_1b"
  }

}


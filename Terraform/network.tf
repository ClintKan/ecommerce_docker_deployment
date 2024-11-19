#Creating the internet gateway
resource "aws_internet_gateway" "wl6vpc_igw" {
  vpc_id = aws_vpc.wl6vpc.id

  tags = {
    "Name" : "wl6vpc_igw"
  }
}

#Creating a public route table 1a
resource "aws_route_table" "pub2a_rttable" {
  vpc_id = aws_vpc.wl6vpc.id

  route {
    cidr_block = "0.0.0.0/0" # this is traffic going out
    gateway_id = aws_internet_gateway.wl6vpc_igw.id
  }
  tags = {
    "Name" : "pub2a_rttable"
  }
}

#Creating a public route table 1b
resource "aws_route_table" "pub2b_rttable" {
  vpc_id     = aws_vpc.wl6vpc.id
  depends_on = [aws_vpc.wl6vpc, aws_nat_gateway.wl6vpc_ngw_2b]

  route {
    cidr_block = "0.0.0.0/0" # this is traffic going out
    gateway_id = aws_internet_gateway.wl6vpc_igw.id
  }
  tags = {
    "Name" : "pub2b_rttable"
  }
}


#Creating public_subnet 1a
resource "aws_subnet" "pub_subnet_2a" {
  vpc_id                  = aws_vpc.wl6vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name" : "pub_subnet_2a"
  }

}

#Creating public_subnet 1b
resource "aws_subnet" "pub_subnet_2b" {
  vpc_id                  = aws_vpc.wl6vpc.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name" : "pub_subnet_2b"
  }

}


#Creating an associ.. btn pub_subnet and pub rttble - for 1a
resource "aws_route_table_association" "pub2a" {
  subnet_id      = aws_subnet.pub_subnet_2a.id
  route_table_id = aws_route_table.pub2a_rttable.id
  depends_on     = [aws_subnet.pub_subnet_2a, aws_route_table.pub2a_rttable]
}

#Creating an associ.. btn pub_subnet and pub rttble - for 1b
resource "aws_route_table_association" "pub1b" {
  subnet_id      = aws_subnet.pub_subnet_2b.id
  route_table_id = aws_route_table.pub2b_rttable.id
  depends_on     = [aws_subnet.pub_subnet_2b, aws_route_table.pub2b_rttable]
}


######--------------------------


#Creating a Private Route Table 1a
resource "aws_route_table" "priv2a_rttable" {
  vpc_id = aws_vpc.wl6vpc.id

  route {
    cidr_block = "0.0.0.0/0" # 10.0.0.0/26" # this is destination the traffic should get to
    gateway_id = aws_nat_gateway.wl6vpc_ngw_2a.id
  }
  tags = {
    "Name" : "priv2a_rttable"
  }

}

#Creating a Private Route Table 1b
resource "aws_route_table" "priv2b_rttable" {
  vpc_id = aws_vpc.wl6vpc.id

  route {
    cidr_block = "0.0.0.0/0" # 10.0.0.64/26 # this is destination the traffic should get to
    gateway_id = aws_nat_gateway.wl6vpc_ngw_2b.id
  }
  tags = {
    "Name" : "priv2b_rttable"
  }

}

#Creating the private_subnet 1a
resource "aws_subnet" "priv_subnet_2a" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.128/27"
  availability_zone = "us-east-2a"
  tags = {
    "Name" : "priv_subnet_2a"
  }

}

#Creating the private_subnet 1b
resource "aws_subnet" "priv_subnet_2b" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.160/27"
  availability_zone = "us-east-2b"
  tags = {
    "Name" : "priv_subnet_2b"
  }

}


#Creating an associ.. btn priv_subnet and priv rttble - for 1a
resource "aws_route_table_association" "priv2a" {
  subnet_id      = aws_subnet.priv_subnet_2a.id
  route_table_id = aws_route_table.priv2a_rttable.id
}

#Creating an associ.. btn priv_subnet and priv rttble - for 1b
resource "aws_route_table_association" "priv2b" {
  subnet_id      = aws_subnet.priv_subnet_2b.id
  route_table_id = aws_route_table.priv2b_rttable.id
}


######------------------

#Creating the RDS private_subnet 1a
resource "aws_subnet" "rds_subnet_2a" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.192/27"
  availability_zone = "us-east-2a"
  tags = {
    "Name" : "rds_subnet_2a"
  }

}

#Creating the RDS private_subnet 1b
resource "aws_subnet" "rds_subnet_2b" {
  vpc_id            = aws_vpc.wl6vpc.id
  cidr_block        = "10.0.0.224/27"
  availability_zone = "us-east-2b"
  tags = {
    "Name" : "rds_subnet_2b"
  }

}

#Creating the RDS Subnet Groups
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.rds_subnet_2a.id, aws_subnet.rds_subnet_2b.id]

  tags = {
    Name = "RDS subnet group"
  }
}


###########--------------------------------------------------------------------------------------



#Creating the nat gateway in AZ 1a
resource "aws_nat_gateway" "wl6vpc_ngw_2a" {
  allocation_id = aws_eip.elastic_ip_2a.id
  subnet_id     = aws_subnet.pub_subnet_2a.id
  depends_on    = [aws_internet_gateway.wl6vpc_igw] # critical to have this for systematic creation of resources

  tags = {
    "Name" : "wl6vpc_ngw_2a"
  }

}

#Creating the nat gateway in AZ 1b
resource "aws_nat_gateway" "wl6vpc_ngw_2b" {
  allocation_id = aws_eip.elastic_ip_2b.id
  subnet_id     = aws_subnet.pub_subnet_2b.id
  depends_on    = [aws_internet_gateway.wl6vpc_igw] # critical to have this for systematic creation of resources

  tags = {
    "Name" : "wl6vpc_ngw_2b"
  }

}


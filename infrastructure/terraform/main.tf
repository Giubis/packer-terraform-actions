provider "aws" {
  region = "eu-west-1"
}

# 1. VPC
resource "aws_vpc" "tech518-giuseppe-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tech518-giuseppe-sparta-vpc"
  }
}

resource "aws_internet_gateway" "tech518-giuseppe-igw" {
  vpc_id = aws_vpc.tech518-giuseppe-vpc.id

  tags = {
    Name = "tech518-giuseppe-sparta-igw"
  }
}

resource "aws_subnet" "tech518-giuseppe-public-subnet" {
  vpc_id     = aws_vpc.tech518-giuseppe-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tech518-giuseppe-sparta-public-subnet"
  }
}

resource "aws_subnet" "tech518-giuseppe-private-subnet" {
  vpc_id     = aws_vpc.tech518-giuseppe-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "tech518-giuseppe-sparta-private-subnet"
  }
}

resource "aws_route_table" "tech518-giuseppe-rt" {
  vpc_id = aws_vpc.tech518-giuseppe-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tech518-giuseppe-igw.id
  }
}

resource "aws_route_table_association" "tech518-giuseppe-public-rt-assoc" {
  subnet_id      = aws_subnet.tech518-giuseppe-public-subnet.id
  route_table_id = aws_route_table.tech518-giuseppe-rt.id
}

# 2. SECURITY GROUPS
resource "aws_security_group" "tech518-giuseppe-app-sg" {
  name   = "tech518-giuseppe-sparta-app-sg"
  vpc_id = aws_vpc.tech518-giuseppe-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
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
}

resource "aws_security_group" "tech518-giuseppe-db-sg" {
  name   = "tech518-giuseppe-sparta-db-sg"
  vpc_id = aws_vpc.tech518-giuseppe-vpc.id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.tech518-giuseppe-app-sg.id]
  }
}

# 3. AMI
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["tech518-giuseppe-sparta-app*"]
  }
}

data "aws_ami" "db_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["tech518-giuseppe-sparta-db*"]
  }
}

# 4. INSTANCES
resource "aws_instance" "tech518-giuseppe-db-instance" {
  ami                    = data.aws_ami.db_ami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.tech518-giuseppe-private-subnet.id
  vpc_security_group_ids = [aws_security_group.tech518-giuseppe-db-sg.id]
  key_name               = "tech518-giuseppe-key-pair"

  tags = {
    Name = "tech518-giuseppe-sparta-db"
  }
}

resource "aws_instance" "tech518-giuseppe-app-instance" {
  ami                         = data.aws_ami.app_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.tech518-giuseppe-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.tech518-giuseppe-app-sg.id]
  associate_public_ip_address = true
  key_name                    = "tech518-giuseppe-key-pair"

  user_data = templatefile("./user-data.sh.tpl", {
    db_ip = aws_instance.tech518-giuseppe-db-instance.private_ip
  })

  tags = {
    Name = "tech518-giuseppe-sparta-app"
  }

  depends_on = [aws_instance.tech518-giuseppe-db-instance]
}

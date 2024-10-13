provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ubuntu_sg" {

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "UbuntuSG"
  }
}

resource "aws_security_group" "amazon_linux_sg" {

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "AmazonLinuxSG"
  }
}

resource "aws_instance" "ubuntu_ec2" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"

  subnet_id     = data.aws_subnets.default.ids

  tags = {
    Name = "UbuntuInstance"
  }

  security_groups = [aws_security_group.ubuntu_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y
    echo "Hello World from Ubuntu $(uname -a)" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
    # Install Docker
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
  EOF
}

resource "aws_instance" "amazon_linux_ec2" {
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"

  subnet_id     = data.aws_subnets.default.ids

  tags = {
    Name = "AmazonLinuxInstance"
  }

  security_groups = [aws_security_group.amazon_linux_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World from Amazon Linux $(uname -a)"
  EOF
}

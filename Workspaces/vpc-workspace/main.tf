provider "aws" {
    region = "us-west-2"
  
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

resource "aws_vpc" "main" {
    cidr_block = ${var.vpc_cidr}

    tags = {
        Name = "my-vpc"
    }
    
   
}

resource "aws_subnet" "subnets"{
  count = 3
  vpc_id = ${aws_vpc.main.id}
  cidr_block = ${cidrsubnet(var.vpc_cidr,8,count.index)}

  tags = {
    Name = "Subnet-${count.index + 0 }"
  }
}

variable "allow_all" { 
    type = map(string)

}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id
  dynamic "ingress" {
    
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
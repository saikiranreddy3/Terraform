provider "aws" {
    region     = "us-west-2"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.10.0.0/16",
    tags = {
        Name = "Dynamic-Vpc"
    }
}

variable "subnet_cidr" {
    type = "list"
    default = ["10.10.0.0/24","10.10.1.0/24","10.10.2.0/24"]

}
/*
variable "azs" {
    type = "list"
    default = ["us-west-2a","us-west-2b","us-west-2c"]
}
*/
data "aws_availability_zones" "azs" {}

resource "aws_subnet" "main_subnets"{
    count = "${length(data.aws_availability_zone.azs.names)}"
    availability_zone = "${element(data.aws_availability_zone.azs.names,count.index)}"
    vpc_id = ${aws_vpc.main_vpc.id}
    cidr_block = "${element(var.subnet_cidr,count.index)}"
    tags = {
        Name = "Subnet-${count.index + 1}"
    }

}
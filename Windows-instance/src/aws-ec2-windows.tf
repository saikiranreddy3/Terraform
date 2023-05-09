provider "aws" {
    access_key = ""
    secret_key = ""
    region = ""
  
}

resource "aws_instance" "name" {
    ami = var.ami
    instance_type = var.type
    subnet_id = var.subnet
    vpc_security_group_ids = ["var.security_group"]
    key_name = var.key_name
    availability_zone = var.availability_zone
    root_block_device {
      
    }
    ebs_block_device {
      
    }
    tags = {
      "s" = "value"
    }
    
  
}
# -----------------------
# VPC
# -----------------------

resource "aws_vpc" "shift_vpc" {

    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
  
}

resource "aws_subnet""public_sb"{


    vpc_id                  = aws_vpc.shift_vpc.id
    cidr_block              = "10.0.1.0/24" 
    availability_zone       = var.az
    map_public_ip_on_launch = true
    
}


resource "aws_internet_gateway" "internet_facing" {

    vpc_id = aws_vpc.shift_vpc.id
  
}



resource "aws_route_table" "public_rt" {

    vpc_id = aws_vpc.shift_vpc.id

    route {

        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_facing.id

        }

    
  
}

resource "aws_route_table_association" "public_association" {
    
        subnet_id      = aws_subnet.public_sb.id 
        route_table_id = aws_route_table.public_rt.id



}

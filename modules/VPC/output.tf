output "vpc_id" {

    value = aws_vpc.shift_vpc.id
  
}

output "public_subnet" {

    value = aws_subnet.public_sb.id
  
}
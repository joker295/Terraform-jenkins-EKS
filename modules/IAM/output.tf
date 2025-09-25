output "ec2_role" {

    value = aws_iam_role.ec2_s3_write_role.name
  
}

output "ec2_instance_profile" {

    value = aws_iam_instance_profile.ec2_s3_profile.name
  
}
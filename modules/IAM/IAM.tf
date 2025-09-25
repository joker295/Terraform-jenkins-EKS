# -------------------
# IAM
#--------------------

# ----------------
# Read Only Role
# ----------------

resource "aws_iam_role" "ec2_s3_read_role" {
  name = "ec2-${var.stage}-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "ec2_s3_read_policy" {
  name        = "s3-${var.stage}-read-policy"
  description = "EC2 policy to read logs files from S3"
    
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}-7070"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}-7070/*"
      }
    ]
  })
}




resource "aws_iam_role_policy_attachment" "ec2_read_attach" {

        role       =  aws_iam_role.ec2_s3_read_role.id
        policy_arn = aws_iam_policy.ec2_s3_read_policy.id

}


# ----------------
# Put_Object Role
# ----------------


resource "aws_iam_role" "ec2_s3_write_role" {
  name = "${var.stage}-ec2-write-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_s3_put_policy" {
  name        = "s3-put-${var.stage}-policy"
  description = "EC2 policy to read and write files to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_write_attach" {

        role       =  aws_iam_role.ec2_s3_write_role.id
        policy_arn = aws_iam_policy.ec2_s3_put_policy.id

}

# ----------------
# Instance Profile
# ----------------

resource "aws_iam_instance_profile" "ec2_s3_profile" {

    name = "aws_profile_attachment" 
    role = aws_iam_role.ec2_s3_write_role.name

}
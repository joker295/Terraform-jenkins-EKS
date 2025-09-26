# -----------------------
# VPC
# -----------------------

resource "aws_vpc" "shift_vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

}

resource "aws_subnet" "public_sb" {


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

# -----------------------
# S3 for config storage 
# -----------------------


resource "aws_s3_bucket" "config_bucket" {

  bucket        = "devops-techeazy-6069"
  force_destroy = true


}


resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2-s3-config-access-role"

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

resource "aws_iam_policy" "ec2_s3_policy" {

  name        = "s3-config-access-policy"
  description = "EC2 policy to read config files from S3"

  policy = jsonencode({

    Version = "2012-10-17"
    Statement = [{

      Action = [
        "s3:GetObject",
      "s3:ListBucket"]
      Effect = "Allow"
      Resource = [
        aws_s3_bucket.config_bucket.arn,
        "${aws_s3_bucket.config_bucket.arn}/*"
      ]

      }

    ]


  })

}

resource "aws_iam_role_policy_attachment" "name" {

  role       = aws_iam_role.ec2_s3_access_role.id
  policy_arn = aws_iam_policy.ec2_s3_policy.id

}

resource "null_resource" "upload_configs" {
  depends_on = [aws_s3_bucket.config_bucket]

  provisioner "local-exec" {
    command = "aws s3 cp config/${var.stage}.json s3://${aws_s3_bucket.config_bucket.bucket}/${var.stage}.json"
  }
}
# -----------------------
# EC2
# -----------------------


# resource "aws_iam_instance_profile" "ec2_s3_profile" {

#   name = "aws_profile_attachment"
#   role = aws_iam_role.ec2_s3_access_role.id

# }

resource "aws_instance" "shift_ec2" {

  count                  = var.instance_count
  subnet_id              = aws_subnet.public_sb.id
  ami                    = var.ami
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_write.name
  instance_type          = var.instance_type
  user_data              = var.user_data
  depends_on             = [aws_security_group.shift_sg]
  vpc_security_group_ids = [aws_security_group.shift_sg.id]



  tags = {

    "Name" = "${var.stage}_instance"

  }
}


# -----------------------
# SG
# -----------------------

resource "aws_security_group" "shift_sg" {

  name        = "${var.stage}_sg"
  vpc_id      = aws_vpc.shift_vpc.id
  description = "Allow traffic HTTP and SSH"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
  }


  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    to_port     = "80"
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
  }
}

### --------------------------------------------------------# ASSIGNMENT - 2 ------------------------------------------------------------------
# ---------------
# S3 - bucket
#----------------


# logs_bucket 

resource "aws_s3_bucket" "logs-bucket" {

  bucket        = var.bucket_name
  force_destroy = true

}



resource "aws_s3_bucket_public_access_block" "block_ip" {

  bucket = aws_s3_bucket.logs-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# S3-lifecycle-rules

resource "aws_s3_bucket_lifecycle_configuration" "lc_rules" {

  bucket = aws_s3_bucket.logs-bucket.id


  rule {

    id     = "delete_logs"
    status = "Enabled"


    filter {

      prefix = ""
    }

    expiration {

      days = 7
    }
  }

}


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
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}-7070"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}-7070/*"
      }
    ]
  })
}




resource "aws_iam_role_policy_attachment" "ec2_read_attach" {

  role       = aws_iam_role.ec2_s3_read_role.id
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

  role       = aws_iam_role.ec2_s3_write_role.id
  policy_arn = aws_iam_policy.ec2_s3_put_policy.id

}

# ----------------
# Instance Profile
# ----------------

resource "aws_iam_instance_profile" "ec2_s3_write" {

  name = "aws_profile_attachment_7070"
  role = aws_iam_role.ec2_s3_write_role.name

}
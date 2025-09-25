# ---------------
# S3 - bucket
# ASSIGNMENT -2
#----------------


# logs_bucket 

resource "aws_s3_bucket" "logs-bucket" {

    bucket        = "${var.bucket_name}"
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


# # -----------------------
# # S3 for config storage 
# # -----------------------


# resource "aws_s3_bucket" "logs_bucket" {

#     bucket        = "devops-techeazy-6069"
#     force_destroy = true
  
  
# }

# resource "null_resource" "upload_configs" {
#   depends_on = [aws_s3_bucket.config_bucket]

#   provisioner "local-exec" {
#     command = "aws s3 cp config/${var.stage}.json s3://${aws_s3_bucket.config_bucket.bucket}/${var.stage}.json"
#   }
# }

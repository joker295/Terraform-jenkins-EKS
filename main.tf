module "VPC" {

  source    = "./modules/VPC"
  region    =  var.region 
  vpc_cidr  =  var.vpc_cidr
  az        =  var.az
  stage     =  var.stage
  
}

module "EC2" {

  source               = "./modules/EC2"
  stage                = var.stage
  public_subnet        = module.VPC.public_subnet  
  instance_count       = var.instance_count
  instance_type        = var.instance_type
  ami                  = var.ami
  user_data            = var.user_data
  vpc_id               = module.VPC.vpc_id
  ec2_instance_profile = module.IAM.ec2_instance_profile
  
}


module "IAM" {

  source      = "./modules/IAM"
  bucket_name = module.S3.s3_logs_bucket 
  stage       = var.stage 

  
}


module "S3" {

  source      = "./modules/S3"
  bucket_name = var.bucket_name


}





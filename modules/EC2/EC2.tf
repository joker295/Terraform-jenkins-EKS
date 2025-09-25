# -----------------------
# EC2
# -----------------------

resource "aws_instance" "shift_ec2" {

    count                  = var.instance_count 
    subnet_id              = var.public_subnet
    ami                    = var.ami
    iam_instance_profile   = var.ec2_instance_profile
    instance_type          = var.instance_type
    user_data              = var.user_data
    depends_on             = [aws_security_group.shift_sg]
    vpc_security_group_ids = [aws_security_group.shift_sg.id] 

    

    tags = { 

        "Name"  = "${var.stage}_instance"

    }
}




# -----------------------
# SG
# -----------------------

resource "aws_security_group" "shift_sg" {

    name         = "${var.stage}_sg"    
    vpc_id       = var.vpc_id
    description  = "Allow traffic HTTP and SSH"

    ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    from_port    = "22"
    to_port      = "22" 
    protocol     = "TCP" 
    }

    
    ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    from_port    = "80"
    to_port      = "80" 
    protocol     = "TCP" 
    }

    egress {
    cidr_blocks   = ["0.0.0.0/0"]
    from_port    = "0"
    to_port      = "0" 
    protocol     = "-1" 
    }
}


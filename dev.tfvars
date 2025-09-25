stage          = "Development"
vpc_cidr       = "10.0.0.0/16"
ami            = "ami-02d26659fd82cf299"
az             = "ap-south-1b"
region         = "ap-south-1"
instance_count = 1
instance_type  = "t3.micro"
bucket_name    = "development-logs-7070" 
user_data =      <<-EOF
            #!/bin/bash
            apt-get update -y 
            apt-get install -y openjdk-21-jdk maven
            cd /home/ubuntu
            git clone https://github.com/Trainings-TechEazy/test-repo-for-devops
            cd test-repo-for-devops
            mvn clean package
            nohup java -jar target/hellomvc-0.0.1-SNAPSHOT.jar --server.port=80 
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            apt install unzip
            unzip awscliv2.zip
            sudo ./aws/install
            aws s3 cp /var/log/cloud-init.log s3://development-logs-7070/system-logs/

    EOF

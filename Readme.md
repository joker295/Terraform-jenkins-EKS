# 🚀 TechEazy DevOps Project

This project involves a **lift-and-shift deployment** of a Java Spring Boot application to **AWS EC2**.
The objective is to simulate a real-world scenario where the application can be deployed on cloud infrastructure as per configuration requirements.

---

## 📋 Overview

This project demonstrates how an application can be configured and deployed on AWS using Terraform and related DevOps practices.

---

## 🏗️ Architecture

* **VPC** – Creation of VPC with Subnet and Internet Gateway
* **EC2 Instance** – Creation of EC2 instance as per requirements
* **S3 Bucket** – Creation of S3 bucket for configuration storage (`dev_config` or `prod_config`)
* **Security Group** – Allow inbound on port **80 (HTTP)**

---

## ⚙️ Configuration

### 1. AWS Credentials Setup

Run:

```bash
aws configure
```

Provide:

* AWS Access Key ID
* AWS Secret Access Key
* Default region (e.g., `us-east-1`)

---

### 2. Initialize Terraform

```bash
terraform init
```

---

### 3. Environment-Specific Deployments

Use the appropriate variable file:

* For **production**:

  ```bash
  terraform apply -var-file="prod.tfvars" --auto-approve
  ```

* For **development**:

  ```bash
  terraform apply -var-file="dev.tfvars" --auto-approve
  ```

Edit `prod.tfvars` or `dev.tfvars` according to your requirements.

---

### 4. Cleanup

To destroy all resources and avoid AWS charges:

```bash
terraform destroy -var-file="dev.tfvars" --auto-approve
```

(or use `prod.tfvars` depending on environment)

---

## 🐛 Troubleshooting

**Application not accessible?**

* Check security group rules
* Verify EC2 instance is running
* Check application logs:

  ```bash
  sudo journalctl -u techeazy
  ```

**Debug Mode (Terraform):**

```bash
export TF_LOG=DEBUG
terraform apply -var-file="dev.tfvars"
```

---

✅ Now your README is clean, structured, and properly indented.

Do you want me to also add a **diagram (ASCII or Mermaid)** of the architecture (VPC → EC2 → S3 → SG) to make it visually clearer?

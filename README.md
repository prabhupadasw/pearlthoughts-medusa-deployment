# Medusa Deployment on AWS ECS Fargate

This project sets up and deploys the [Medusa backend](https://medusajs.com/) on **AWS ECS Fargate** using **Terraform**. It’s part of an internship task at **PearlThoughts** to demonstrate infrastructure-as-code (IaC) and DevOps skills.

---

## 🛠️ Stack Used

- **Terraform** for infrastructure provisioning  
- **AWS ECS Fargate** to run containerized Medusa backend  
- **GitHub** for source code management  
- **CloudWatch** for logging  

---

## 📦 What It Does

- Provisions:
  - ECS Cluster
  - Task Definition for Medusa container
  - ECS Fargate Service
  - Security Group to allow HTTP traffic on port 9000
  - IAM Role for ECS task execution
  - CloudWatch log group


## 📁 Folder Structure
medusa-ecs-terraform/ └── terraform/ ├── main.tf # Main Terraform configuration (ECS, IAM, networking, etc.) ├── .gitignore # Ignoring sensitive or unnecessary Terraform files └── README.md 


🚀 Deployment Steps

1. Navigate into the `terraform` directory  
2. Initialize Terraform  
   ```bash
   terraform init
   terraform apply

ECS setup is complete and pushed to GitHub. Medusa container pulling issue may require authentication for private registries







(This deployment is part of an internship assignment from PearlThoughts, demonstrating DevOps proficiency using Infrastructure as Code (IaC) with Terraform and AWS ECS Fargate.)
   

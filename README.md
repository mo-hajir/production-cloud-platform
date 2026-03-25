# Production Cloud Platform

This project demonstrates a **production-grade cloud infrastructure on AWS** built using **Terraform and GitHub Actions (CI/CD)**.

It follows best practices for:
- Infrastructure as Code (IaC)
- Multi-environment deployments (dev, staging, prod)
- High availability and scalability
- Security and monitoring

---

## 🚀 Project Overview

- **Cloud Provider:** AWS  
- **Region:** ca-central-1  
- **IaC Tool:** Terraform  
- **CI/CD:** GitHub Actions (OIDC authentication)  
- **Environments:** dev, staging, prod  

---

## 🏗️ Architecture

This platform is designed to be **highly available, scalable, and secure**.

### 🔹 Components

- **VPC** with public & private subnets  
- **Internet Gateway** for public access  
- **NAT Gateway** for private subnet outbound traffic  
- **Application Load Balancer (ALB)** for traffic distribution  
- **Auto Scaling Group (ASG)** for dynamic scaling  
- **EC2 Instances** (private app servers)  
- **Bastion Host** for secure SSH access  
- **Security Groups** for network control  
- **CloudWatch** for monitoring  
- **SNS** for alerts  

---

## 📊 Architecture Diagram
                ┌─────────────────────┐
                │      Internet       │
                └─────────┬──────────┘
                          │
                          ▼
                ┌─────────────────────┐
                │   Load Balancer     │
                │       (ALB)         │
                └─────────┬──────────┘
                          │
           ┌──────────────┴──────────────┐
           │                             │
           ▼                             ▼
┌─────────────────┐           ┌─────────────────┐
│  EC2 Instance   │           │  EC2 Instance   │
│   (Private)     │           │   (Private)     │
└─────────────────┘           └─────────────────┘
           ▲
           │
  ┌────────┴────────┐
  │ Auto Scaling     │
  │ Group (ASG)      │
  └────────┬────────┘
           │
           ▼
┌─────────────────────┐
│   Private Subnets   │
└─────────────────────┘

┌─────────────────────┐
│   Public Subnets    │
│  (Bastion Host)     │
└─────────────────────┘

┌─────────────────────┐
│   NAT Gateway       │
└─────────────────────┘

┌─────────────────────┐
│ CloudWatch + SNS    │
└─────────────────────┘
---

## 🔄 CI/CD Pipeline

- Triggered on push to:
  - `dev`
  - `staging`
  - `main`

### Workflow Steps:

1. Checkout code  
2. Configure AWS credentials (OIDC)  
3. Terraform Init  
4. Terraform Format Check  
5. Terraform Validate  
6. Security Scan (tfsec)  
7. Terraform Plan  
8. Terraform Apply (staging + prod only)  

---

## 🔐 Security

- **OIDC Authentication** (no hardcoded AWS keys)  
- IAM roles with scoped permissions  
- Bastion host for controlled SSH access  
- Private subnets for application servers  
- Security groups restricting traffic:
  - ALB → public HTTP  
  - App servers → only from ALB  
  - Bastion → restricted SSH access  
- Secrets managed via GitHub Actions  

---

## 📈 Monitoring & Alerts

- **CloudWatch Logs**  
- **CPU Utilization Alarms**  
- **SNS Notifications** (email alerts)  

---

## 💰 Cost Estimation (Approx Monthly)

| Service              | Cost Estimate |
|---------------------|--------------|
| EC2 (t2.micro x2-3) | $15 - $25    |
| ALB                 | $16 - $20    |
| NAT Gateway         | $30 - $40    |
| EBS Volumes         | $5 - $10     |
| CloudWatch + SNS    | $5 - $10     |

**Estimated Total:** ~$70 - $100/month  

> Resources are destroyed after testing to avoid unnecessary charges.

---

## 🚀 Deployment

### 1. Clone Repository

```bash
git clone https://github.com/mo-hajir/production-cloud-platform.git
cd production-cloud-platform

cd terraform/environments/dev

terraform init
terraform plan
terraform apply

terraform destroy

## 📌 Key Features

- **Multi-Environment Infrastructure**  
  Separate `dev`, `staging`, and `prod` environments using Terraform for safe and controlled deployments  

- **Infrastructure as Code (IaC)**  
  Fully modular Terraform setup for reusable, maintainable, and scalable infrastructure  

- **High Availability Architecture**  
  Application Load Balancer (ALB) distributes traffic across multiple EC2 instances in an Auto Scaling Group  

- **Auto Scaling**  
  Dynamic scaling of EC2 instances based on CPU utilization using AWS Auto Scaling policies  

- **Secure Network Design**  
  - Public and private subnets  
  - Bastion host for controlled SSH access  
  - Security groups enforcing least privilege access  

- **CI/CD Automation**  
  GitHub Actions pipeline automates Terraform plan and apply across environments  

- **Monitoring & Alerting**  
  CloudWatch metrics and alarms integrated with SNS for real-time notifications  

- **Cost Optimization**  
  Resources are destroyed after testing to minimize AWS costs  

## 🧠 System Design Decisions

- **ALB + ASG Architecture**  
  Ensures high availability and fault tolerance by distributing traffic and automatically replacing unhealthy instances  

- **Private Subnets for Application Layer**  
  Application servers are not exposed to the internet, reducing attack surface  

- **Bastion Host Access Pattern**  
  Secure SSH access through a single controlled entry point instead of exposing instances publicly  

- **OIDC Authentication (GitHub Actions → AWS)**  
  Eliminates the need for long-lived AWS credentials, improving security  

- **Modular Terraform Design**  
  Infrastructure split into reusable modules (VPC, EC2, ALB, ASG, etc.) for scalability and maintainability  

- **Separation of Environments**  
  Isolated environments (dev, staging, prod) allow safe testing before production deployment  

- **Monitoring First Approach**  
  Integrated CloudWatch and SNS ensures visibility into system health and performance   

## 🏁 Conclusion

This project demonstrates the design and implementation of a **production-ready cloud infrastructure** using modern DevOps practices.

It showcases:

- Scalable and highly available architecture  
- Secure networking and access control  
- Automated infrastructure deployment via CI/CD  
- Monitoring and alerting for operational visibility  

Overall, this project reflects real-world cloud engineering practices and provides a strong foundation for building and managing reliable cloud-native systems. 
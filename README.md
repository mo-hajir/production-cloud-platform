# Production Cloud Platform

This repository contains the Terraform configuration and infrastructure setup for a production-grade cloud platform on **AWS**.  

It demonstrates best practices for modular Terraform, networking setup, and Git workflows.

---

## **Project Overview**

- **Infrastructure as Code (IaC)** with Terraform  
- **Environment:** Dev  
- **Region:** `ca-central-1`  
- **Modules:**
  - `vpc` – Creates VPC, public and private subnets  
  - `igw` – Internet Gateway and public route table  
  - `nat` – NAT Gateway and private route table  

---

## **Architecture Diagram**

      ┌─────────────────────┐
      │       Internet      │
      └─────────┬──────────┘
                │
                ▼
       ┌───────────────────┐
       │  Internet Gateway  │
       └─────────┬─────────┘
                 │
     ┌───────────┴───────────┐
     │       VPC: 10.0.0.0/16 │
     └───────────┬───────────┘
      Public Subnets │ Private Subnets
      
> **Note:** NAT Gateway and other resources were provisioned during testing and destroyed after verification to avoid AWS charges.

---

## **Terraform Setup**

### **1. Initialize Environment**
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
terraform destroy
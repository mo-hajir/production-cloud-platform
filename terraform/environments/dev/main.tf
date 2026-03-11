terraform {
  backend "s3" {
    bucket         = "tf.state.production.cloud.platform.1"
    key            = "production-cloud-platform/dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

module "vpc" {
  source          = "../../modules/vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
}
module "igw" {
  source = "../../modules/igw"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}
module "nat" {
  source = "../../modules/nat"

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
}
module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id = module.vpc.vpc_id
  my_ip  = "105.160.100.30/32"
}
module "ec2" {
  source = "../../modules/ec2"

  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  private_subnet_id = module.vpc.private_subnet_ids[0]
  bastion_sg        = module.security_groups.bastion_sg
  app_sg            = module.security_groups.app_sg
}
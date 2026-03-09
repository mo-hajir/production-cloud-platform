variable "vpc_id" {
  description = "VPC where NAT will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet for NAT Gateway"
  type        = string
}
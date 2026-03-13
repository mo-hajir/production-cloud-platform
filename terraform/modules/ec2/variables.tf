variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet for bastion"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet for app server"
  type        = string
}

variable "bastion_sg" {
  description = "Security group for bastion"
  type        = string
}

variable "app_sg" {
  description = "Security group for app"
  type        = string
}
variable "public_key" {
  description = "Public SSH key for bastion host"
  type        = string
}
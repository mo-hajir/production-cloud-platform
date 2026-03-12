variable "private_subnet_ids" {
  description = "Private subnets for EC2 instances"
  type        = list(string)
}

variable "app_sg" {
  description = "Security group for application instances"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN"
  type        = string
}
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_eip.bastion_eip.public_ip
}

output "app_private_ip" {
  description = "Private IP of the application server"
  value       = aws_instance.app.private_ip
}
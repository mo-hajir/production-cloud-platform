output "bastion_sg" {
  value = aws_security_group.bastion.id
}

output "app_sg" {
  value = aws_security_group.app.id
}
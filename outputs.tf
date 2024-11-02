output "jumpbox_ipv4" {
  value = aws_instance.jumpbox.public_ip
}

output "jumpbox_instance_id" {
  value = aws_instance.jumpbox.id
}

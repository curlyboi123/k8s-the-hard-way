output "jumpbox_ipv4" {
  value = aws_instance.jumpbox.public_ip
}

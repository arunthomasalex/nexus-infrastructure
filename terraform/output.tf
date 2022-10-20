output "nexus-ip" {
  value = aws_instance.nexus.public_ip
}

output "nexus-details" {
  value = aws_instance.nexus
}

output "nexus-id" {
  value = aws_instance.nexus.id
}
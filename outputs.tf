
output "instance_ip" {
  value = aws_instance.ec2_terraform_instance.public_ip
}
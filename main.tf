##################################
## SSH Key Pair Generation
##################################

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "ec2-keypair2"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

##################################
## EC2 Instance
##################################

resource "aws_instance" "ec2_terraform_instance" {
  ami           = var.ami
  instance_type = "t2.small"
  key_name      = aws_key_pair.ec2_keypair.key_name
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "Kiran-ec2-docker-Instance"
  }

  provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo amazon-linux-extras install docker -y",
    "sudo service docker start",
    "sudo usermod -a -G docker ec2-user",
    "sudo docker run -d -p 80:80 your_docker_image",
]
    connection {
      type        = "ssh"
      user        = "linux"
      private_key = tls_private_key.ec2_key.private_key_pem
      host        = self.public_ip
    }
  }

}

##################################
## Security Group
##################################

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group2"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2 Security Group"
  }
}

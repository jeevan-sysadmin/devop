provider "aws" {
  region = "ap-south-1"  # AWS Mumbai region
}

# Fetch the default VPC ID dynamically
data "aws_vpc" "default" {
  default = true
}

# Create a new Security Group if needed
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg-${terraform.workspace}"  # Unique name to avoid conflicts
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = data.aws_vpc.default.id  # Use default VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP for security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# EC2 Instance for Web Server
resource "aws_instance" "web_server100" {
  ami             = "ami-03f4878755434977f"  # Ubuntu 22.04 AMI for ap-south-1
  instance_type   = "t2.micro"
  key_name        = "jeeva12"  # Replace with your actual key pair name
  security_groups = [aws_security_group.web_sg.name]  # Attach security group

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              
              # Install OpenJDK 11
              sudo apt install -y openjdk-11-jdk

              # Verify Java installation
              java -version | tee /home/ubuntu/java_version.txt

              # Install Docker
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              # Verify Docker installation
              docker --version | tee /home/ubuntu/docker_version.txt

              # Run Nginx in Docker
              sudo docker run -d -p 80:80 nginx
              EOF

  tags = {
    Name = "web server"
  }
}

# Output the Public IP of the EC2 Instance
output "public_ip" {
  value = aws_instance.web_server100.public_ip
}

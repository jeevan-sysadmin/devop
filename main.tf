provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "react_ec2" {
  ami           = "ami-0a7cf821b91bcccbc" # Ubuntu 22.04 LTS (Mumbai)
  instance_type = "t2.micro"
  key_name      = devops  # Use variable for key name
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    # Update system packages
    sudo apt update -y && sudo apt upgrade -y

    # Install Java (OpenJDK 11)
    sudo apt install -y openjdk-11-jdk

    # Install Docker
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu

    # Install Git
    sudo apt install -y git

    # Install Jenkins Agent dependencies
    sudo apt install -y wget

    # Verify installations
    java -version
    docker --version
    git --version
  EOF

  tags = {
    Name = "Jenkins-Slave-Server-Ubuntu"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "react-security-group"
  description = "Allow inbound access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}

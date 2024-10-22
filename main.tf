terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48"
    }
  }
}

variable "aws_key_pair" {
  default = "\\aws-key-pair\\default-ec2.pem"
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 5.48"
}

resource "aws_security_group" "elb_sg" {
  name        = "elb_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTP traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound SSH traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_default_vpc" "default" {
}

data "aws_subnet" "default_subnets" {
  vpc_id            = aws_default_vpc.default.id
  availability_zone = "us-east-1a" // Specify the desired availability zone
}


resource "aws_elb" "elb" {
  name               = "elb"
  availability_zones = ["us-east-1a", "us-east-1b"]
  security_groups    = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
}

resource "aws_instance" "http_servers" {
  ami                    = "ami-07caf09b362be10b8" // Update with correct AMI ID
  key_name               = "default-ec2"           // Update with your key pair name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.elb_sg.id]

  count = 6

  subnet_id = data.aws_subnet.default_subnets.id


  tags = {
    Name = "http_server_${count.index + 1}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "echo 'Welcome To My HTTP server ${self.public_dns}' | sudo tee /var/www/html/index.html"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }
}




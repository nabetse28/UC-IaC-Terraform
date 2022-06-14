
variable "private_ssh_key" {}
variable "public_ssh_key" {}
variable "vpc_id" {}
variable "resource" {}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-0022f*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_ssh_key)

  tags = {
    "Resources" = "Test-${var.resource}"
  }
}

resource "aws_security_group" "allow_ssh_and_http" {
  name        = "TerraformSG_SSH_and_HTTP"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Request for server"
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
    "Resources" = "Test-${var.resource}"
  }
}

resource "aws_instance" "server_http" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_ssh_and_http.id
  ]
  tags = {
    "Resources" = "Test-${var.resource}"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    private_key = file(var.private_ssh_key)
  }

  user_data_base64 = "IyEvYmluL2Jhc2gKIyBVc2UgdGhpcyBmb3IgeW91ciB1c2VyIGRhdGEgKHNjcmlwdCBmcm9tIHRvcCB0byBib3R0b20pCiMgaW5zdGFsbCBodHRwZCAoTGludXggMiB2ZXJzaW9uKQp5dW0gdXBkYXRlIC15Cnl1bSBpbnN0YWxsIC15IGh0dHBkCnN5c3RlbWN0bCBzdGFydCBodHRwZApzeXN0ZW1jdGwgZW5hYmxlIGh0dHBkCmVjaG8gIjxoMT5IZWxsbyBXb3JsZCBmcm9tICQoaG9zdG5hbWUgLWYpPGgxPiIgPiAvdmFyL3d3dy9odG1sL2luZGV4Lmh0bWw="
}

output "ip_instance" {
  value = aws_instance.server_http.public_ip
}

output "ssh" {
  value = "ssh -i ${var.private_ssh_key} ec2-user@${aws_instance.server_http.public_dns}"
}

output "http" {
  value = "http://${aws_instance.server_http.public_ip}"
}

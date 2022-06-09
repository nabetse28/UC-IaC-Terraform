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

variable "ssh_key" {}
variable "vpc_id" {}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh_key)

  tags = {
    "Resources" = "Test"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "TerraformSSH"
  description = "Allow SSH inbound traffic"
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
    "Resources" = "Test"
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  # get_user_data = true
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id
  ]
  tags = {
    "Resources" = "Test"
  }

  user_data_base64 = "IyEvYmluL2Jhc2gKIyBVc2UgdGhpcyBmb3IgeW91ciB1c2VyIGRhdGEgKHNjcmlwdCBmcm9tIHRvcCB0byBib3R0b20pCiMgaW5zdGFsbCBodHRwZCAoTGludXggMiB2ZXJzaW9uKQp5dW0gdXBkYXRlIC15Cnl1bSBpbnN0YWxsIC15IGh0dHBkCnN5c3RlbWN0bCBzdGFydCBodHRwZApzeXN0ZW1jdGwgZW5hYmxlIGh0dHBkCmVjaG8gIjxoMT5IZWxsbyBXb3JsZCBmcm9tICQoaG9zdG5hbWUgLWYpPGgxPiIgPiAvdmFyL3d3dy9odG1sL2luZGV4Lmh0bWw="
}

output "ip_instance" {
  value = aws_instance.server.public_ip
}

output "ssh" {
  value = "ssh -l amazon_linux ${aws_instance.server.public_ip}"
}

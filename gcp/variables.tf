# Global

# Parameters

variable "region" {
  type    = string
  default = "us-central1"
}

variable "project_id" {
  type = string
}

variable "user" {
  type = string
}

variable "ssh_private_key" {
  type    = string
  default = "~/.ssh/terraform"
}

variable "ssh_public_key" {
  type    = string
  default = "~/.ssh/terraform.pub"
}

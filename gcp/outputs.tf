output "http" {
  value = "http://${google_compute_address.static.address}"
}

output "ssh" {
  value = "ssh -i ${var.ssh_private_key} ${var.user}@${google_compute_address.static.address}"
}

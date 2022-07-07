resource "google_compute_network" "vpc_network" {
  name                    = "terraform-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "ssh_http_rule" {
  name    = "terraform-ssh-and-http"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-and-http"]
}

resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project_id
  region     = var.region
  depends_on = [google_compute_firewall.ssh_http_rule]
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-test"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      size  = "10"
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static.address
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file(var.ssh_private_key)
    }

    inline = ["echo Terraform"]
  }

  metadata_startup_script = file("./test.sh")

  depends_on = [
    google_compute_network.vpc_network,
    google_compute_firewall.ssh_http_rule
  ]

  metadata = {
    "ssh-keys" = "${var.user}:${file(var.ssh_public_key)}"
  }

  tags = ["ssh-and-http"]

}

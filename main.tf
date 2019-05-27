provider "google" {
  project     = "projet1-241907"
  credentials = "${file("projet1-241907-caf58fbb5357.json")}"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.0.0.0/26"
  region        = "us-central1"
  network       = "${google_compute_network.vpc_network.name}"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network.name}"
    subnetwork    = "test-subnetwork"
    access_config = {}
  }

  metadata {
    ssh-keys = "root:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["web"]
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "${google_compute_network.vpc_network.name}"

  # allow {
  #   protocol = "icmp"
  # }

  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "1000-2000"]
  }
  target_tags = ["web"]
}

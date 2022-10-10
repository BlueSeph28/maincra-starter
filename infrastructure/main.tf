# https://console.cloud.google.com/projectselector/iam-admin/serviceaccounts/create?_ga=2.117243718.1170366991.1665417377-1266140962.1664402679&_gac=1.196159326.1664403025.CjwKCAjw4c-ZBhAEEiwAZ105RUjsysQV6gEd2MzPmGaxd7bfKg4JwQhfQY55SGlOsNLzLOBf9PWOAhoCS5gQAvD_BwE
# gcloud services enable storage.googleapis.com

terraform {
  required_version = ">= 1.2.0"
  #backend "gcs" {
  # bucket  = "BUCKET_NAME"
  # prefix  = "terraform/state"
 #}
}

provider "google" {
  project     = var.gcp_project
  credentials = file("./../secret.json")
  region      = "us-west2"
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west2"
  network       = google_compute_network.vpc_network.id
}


resource "google_compute_instance" "default" {
  name         = "maincra"
  machine_type = "e2-medium"
  zone         = "us-west2-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Flask
  metadata_startup_script = "${file("./../utils/install.sh")}"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {}
  }

  metadata = {
    ssh-keys = "maincra:${file("./../creds/gcloud_instance.pub")}"
  }

  provisioner "file" {
  source = "creds/test_file"
  destination = "/tmp/test_file"

  connection {
    host = "${self.network_interface.0.access_config.0.nat_ip}"
    type = "ssh"
    user = "maincra"
    private_key = "${file("./../creds/gcloud_instance")}"
    agent = "false"
  }
}
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "https" {
  name = "default0-allow-https"
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https"]
}

resource "google_compute_firewall" "http" {
  name = "default0-allow-http"
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

resource "google_compute_firewall" "maincra-ingress" {
  name = "maincra-ingress"
  allow {
    ports    = ["19132", "25565", "25575"]
    protocol = "tcp"
  }
  allow {
    ports    = ["19132", "25565", "25575"]
    protocol = "udp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["maincra-ingress"]
}

resource "google_compute_firewall" "maincra-egress" {
  name = "maincra-egress"
  allow {
    ports    = ["19132", "25565", "25575"]
    protocol = "tcp"
  }
  allow {
    ports    = ["19132", "25565", "25575"]
    protocol = "udp"
  }

  direction     = "EGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["maincra-egress"]
}
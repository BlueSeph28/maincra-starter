resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
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
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {}
  }

  metadata {
    ssh-keys = "maincra:${file("./creds/gcloud_instance.pub")}"
  }

  provisioner "file" {
  source = "creds/test_file"
  destination = "/tmp/test_file"

  connection {
    type = "ssh"
    user = "maincra"
    private_key = "${file("./creds/gcloud_instance")}"
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

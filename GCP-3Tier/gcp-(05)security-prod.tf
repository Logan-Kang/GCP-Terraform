# Allow PING testing.

resource "google_compute_firewall" "gcp-prod-allow-icmp" {
  name    = "${google_compute_network.gcp-prod-network.name}-gcp-allow-icmp"
  network = "${google_compute_network.gcp-prod-network.name}"

  source_ranges = [
    "0.0.0.0/0",
  ]

  allow {
    protocol = "icmp"
  }
}

# Allow SSH for iperf testing.

resource "google_compute_firewall" "gcp-prod-allow-ssh" {
  name    = "${google_compute_network.gcp-prod-network.name}-gcp-allow-ssh"
  network = "${google_compute_network.gcp-prod-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0",
  ]

  target_tags = ["stf"]
}


resource "google_compute_firewall" "gcp-prod-allow-ssh-tag" {
  name    = "${google_compute_network.gcp-prod-network.name}-gcp-allow-ssh-tag"
  network = "${google_compute_network.gcp-prod-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["bastion"]
  target_tags = ["was", "web", "db"]
}

# Allow TCP traffic from the Internet.
resource "google_compute_firewall" "gcp-prod-allow-internet" {
  name    = "${google_compute_network.gcp-prod-network.name}-gcp-allow-internet"
  network = "${google_compute_network.gcp-prod-network.name}"

  source_ranges = [
    "209.85.204.0/22",
    "130.211.0.0/22",
    "35.191.0.0/16",
    "209.85.152.0/22",
  ]

  target_tags = ["web-prod"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "gcp-prod-allow-was-80" {
  name        = "${google_compute_network.gcp-prod-network.name}-gcp-allow-was-80"
  network     = "${google_compute_network.gcp-prod-network.name}"
  source_tags = ["web-prod"]
  target_tags = ["was-prod"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "gcp-prod-allow-was-tag" {
  name        = "${google_compute_network.gcp-prod-network.name}-gcp-allow-was-tag"
  network     = "${google_compute_network.gcp-prod-network.name}"
  source_tags = ["web-prod"]
  target_tags = ["was-prod"]

  allow {
    protocol = "tcp"
    ports    = ["8009", "8443"]
  }
}

resource "google_compute_firewall" "gcp-prod-allow-mysql-tag" {
  name    = "${google_compute_network.gcp-prod-network.name}-gcp-allow-mysql-tag"
  network = "${google_compute_network.gcp-prod-network.name}"

  source_tags = ["was-prod"]
  target_tags = ["db"]

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}

resource "google_compute_firewall" "gcp-prod-allow-was-healthcheck" {
  name    = "${google_compute_network.gcp-prod-network.name}-gcp-allow-was-healthcheck"
  network = "${google_compute_network.gcp-prod-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8009"]
  }

  source_ranges = [
    "209.85.204.0/22",
    "130.211.0.0/22",
    "35.191.0.0/16",
    "209.85.152.0/22",
  ]

  target_tags = ["was-prod"]
}

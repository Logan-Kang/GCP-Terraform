resource "google_compute_address" "natgw-ip" {
  name   = "${random_string.prefix.result}-natgw-ip-${var.gcp_regions[0]}"
  region = "${var.gcp_regions[0]}"
}

resource "google_compute_instance" "natgw" {
  name                      = "${random_string.prefix.result}-natgw"
  machine_type              = "${var.gcp_inst_type_n1-std[1]}"
  zone                      = "${data.google_compute_zones.zones.0.names[0]}"
  can_ip_forward            = true
  tags                      = ["stf", "natgw"]
  depends_on                = ["google_compute_instance.bastion-vm"]
  allow_stopping_for_update = true

  service_account {
    scopes = ["logging-write"]
  }

  boot_disk {
    initialize_params {
      image = "${var.gcp_disk_img_ubnt_1604}"
      size  = "10"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.gcp-prod-subnets.0.name}"

    access_config {
      # Static IP
      nat_ip = "${google_compute_address.natgw-ip.address}"
    }
  }

  metadata {
    sshKeys = "${var.sshKeys}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf > /dev/null",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q iptables-persistent",
      "curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh",
      "sudo bash install-logging-agent.sh",
    ]

    connection {
      type        = "ssh"
      user        = "cheolgon_kang"
      agent       = false
      private_key = "${file("../id_rsa")}"
    }
  }
}

resource "google_compute_route" "natgw" {
  name                   = "${random_string.prefix.result}-natroute"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.gcp-prod-network.name}"
  next_hop_instance      = "${google_compute_instance.natgw.name}"
  next_hop_instance_zone = "${data.google_compute_zones.zones.0.names[0]}"
  priority               = 1000
  tags                   = ["internal"]
}

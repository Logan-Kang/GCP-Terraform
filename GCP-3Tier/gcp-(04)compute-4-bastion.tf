resource "google_compute_address" "bastion-ip" {
  name   = "${random_string.prefix.result}-bastion-ip-${var.gcp_regions[0]}"
  region = "${var.gcp_regions[0]}"
}

resource "google_compute_instance" "bastion-vm" {
  name                      = "${random_string.prefix.result}-bastion"
  machine_type              = "${var.gcp_inst_type_n1-std[1]}"
  zone                      = "${data.google_compute_zones.zones.0.names[0]}"
  depends_on                = ["google_compute_instance.was-vm", "google_compute_instance.web-vm"]
  tags                      = ["stf", "bastion"]
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
      nat_ip = "${google_compute_address.bastion-ip.address}"
    }
  }

  metadata {
    sshKeys = "${var.sshKeys}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y nginx",
      "sudo apt install -y software-properties-common",
      "sudo DEBIAN_FRONTEND=noninteractive apt-add-repository -y ppa:ansible/ansible",
      "sudo apt update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ansible",
      "sudo bash -c cat > ~/bastion.pem << EOF",
      "-----BEGIN RSA PRIVATE KEY-----",
      "MIIEowIBAAKCAQEAu31R8DKX+j63VKmvFK9D9Dn+XNCsSxpgOfZ7uBz3KzXGX3rc",
      "g51ff0cT+QxOgNzPagnWy+f+HUGKF/PJSnbXMhZ+cFyFFzBPh3sKWPT1El1My5mh",
      "phi+N7XS6m/fHcTKir+MxiD0Va3DrF9F7X7Y4FmYg/WCPOIqWhUWhaEOlLx/M5Xd",
      "9MjJnrCg/45gzDPdquM2cSKb809yBHc6bVn4U6brTurS1I9cSH7BGxExquFGsTcE",
      "mydP8NbH4eFOS7CIAYwzhoekZkphbx6lEMXJkdNHvCTJvo5hbbnRw8jA6NZWICiR",
      "HC3IW2NDEcXUs1uYVlRUV15Rpxo3NwBdWeWtgQIDAQABAoIBAGqd9T52Rt5TU8Wd",
      "SKamlCoJ4I+/Snra4OWVOP2V2yiDR+972nItx+SE8uKpEOtOpdRTDAagQm04m+LL",
      "CyiBNBaTnAshUb3CBzevzE6R3ds3mzgcgUQGxgTALNSMEYDIK7WC//abPtaKHb+j",
      "3gwUGhhaWtSPhCRDKHpZi5kp4TTKktoA5KJwnCVmULNHlhEGC013T1INwKN2w3AC",
      "mPWDGFPqKzjIbsx07TZ593F0iGs4SDoMg0Y5jXmPWenPeSEwxeP4tqmM0ivPO0fN",
      "R8sGBtOsgL70k1MF2Jkmf0C6W5se/OMJoXlQx/vuWt4sxtSnLMLvzr3maf+tDzDI",
      "anbYYpECgYEA5ET/hyv1bQyMJ7TOM6CyhfbTD/MnNdIJVRRes2r6SIbfo/16pVco",
      "QPH5OFSjXygCaG456PqlvEWwRDj1WthT6+dmxPSIeG/1sFHg4tCU8VQf2OhUWiUZ",
      "3preyQkLmE5o59MnXLN4V9Px3NhJVdev3RME7gNjDvpMJJ4eBu6tSrMCgYEA0kQY",
      "q432S0092QmE5mnSUGXfwjFlsAiorenDH48U0+IxbUVEtmZhE/NrQN9nysO17ooQ",
      "07qvjB5auTs5sJFhc7TSaCcWsZOuFGTeePfqKXpRqwhQIbu86iSMxx7aTx2HOzw6",
      "Bd7s4OdZEDEGpClcbJUvyj+5Jv3eGW0d1GeE0PsCgYEAvWizTwoev7mlolzYrOYu",
      "vBIu2BE++92oeLxKSD4AJ6YidASkfAVyFVGzJha06QRd2yF7U+KHG04IENPiYtsV",
      "560/DTaK9sSP7RpDrHC+5fCT7Hv7YkFe0eNX8SBcSqjlS1deVgFlXhszmbiuQViT",
      "SLG7aXPOAmOWQtwgtkfd6xkCgYBnLJ7mX0yBeq9kdjVOUpKufK6lPVPmYvlSDSh/",
      "rdfMeGtEcP7cebQc9A6m0Hi/l/UHzZugKTTGjoZ56cPPDidBfXLZRITwMcTzoONB",
      "fHTcUXcNc5DOXK7APZsOgechdx3KRS07gD2/xgV/2m6l0t3VMgc3OLmDloKK+23t",
      "sbYMTQKBgEdwHXa2WO3IuyQYwB6l9zk7uwyEjwRacmzRCuxnsHBT1PfNtjPyC6El",
      "MhpqPuaxS7ezIpm9hUPw1gNlztUV+xCIGPou7yTQjXQ2JT/YcbVk8JenTtCN1Ck2",
      "P9yryCPmzpCF4fw0UKLgMvIVSCl8TRTsE/6U+xw9FB48v2xWezRk",
      "-----END RSA PRIVATE KEY-----",
      "EOF",
      "sudo chmod 400 bastion.pem",
      "cp bastion.pem ~/.ssh/id_rsa",
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

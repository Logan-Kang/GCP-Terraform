resource "google_compute_address" "web-ip" {
  count  = "${var.count}"
  name   = "${random_string.prefix.result}-web-ip-${element(var.gcp_regions,count.index)}"
  region = "${element(var.gcp_regions,count.index)}"
}

resource "google_compute_instance" "web-vm" {
  count                     = "${var.count}"
  name                      = "${random_string.prefix.result}-web-${count.index}"
  machine_type              = "${var.gcp_inst_type_n1-std[1]}"
  zone                      = "${element(var.zone1,count.index)}"
  depends_on                = ["google_compute_instance.was-vm"]
  tags                      = ["stf", "web"]
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
    subnetwork = "${element(google_compute_subnetwork.gcp-prod-subnets.*.name,count.index)}"

    access_config {
      # Static IP
      nat_ip = "${element(google_compute_address.web-ip.*.address,count.index)}"
    }
  }

  metadata {
    sshKeys = "${var.sshKeys}"
  }

  provisioner "file" {
    source      = "../000-default.conf"
    destination = "~/000-default.conf"

    connection {
      type        = "ssh"
      user        = "cheolgon_kang"
      agent       = false
      private_key = "${file("../id_rsa")}"
    }
  }
## because of hanging, replace with an apt-get(apache2)
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y apache2",
      "sudo apt-get install -y libapache2-mod-jk",
      "sudo bash -c cat > ~/workers.properties << EOF",
      "workers.tomcat_home=/usr/share/tomcat8",
      "workers.java_home=/usr/lib/jvm/java-default",
      "worker.list=tomcat1",
      "worker.tomcat1.port = 8009",
      "worker.tomcat1.host = ${element(var.inernal_lb_addresses,count.index)}",
      "worker.tomcat1.type = ajp13",
      "worker.tomcat1.lbfactor = 20",
      "EOF",
      "sudo cp ~/workers.properties /etc/apache2/workers.properties",
      "sudo sed '23d' /etc/apache2/mods-available/jk.conf > ~/jk1.conf",
      "sudo sed '23a JkWorkersFile /etc/apache2/workers.properties' ~/jk1.conf > ~/jk2.conf",
      "sudo rm /etc/apache2/mods-available/jk.conf",
      "sudo cp ~/jk2.conf /etc/apache2/mods-available/jk.conf",
      "sudo rm /etc/apache2/sites-available/000-default.conf",
      "sudo cp ~/000-default.conf /etc/apache2/sites-available/000-default.conf",
      "sudo ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/mods-headers.load",
      /*"sudo /etc/init.d/apache2 restart",*/
      "sudo service apache2 restart",
      "sudo apt install -y software-properties-common",
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

#

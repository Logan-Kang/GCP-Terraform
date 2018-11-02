resource "google_compute_address" "was-ip" {
  count  = "${var.count}"
  name   = "${random_string.prefix.result}-was-ip-${element(var.gcp_regions,count.index)}"
  region = "${element(var.gcp_regions,count.index)}"
}

resource "google_compute_instance" "was-vm" {
  count                     = "${var.count}"
  name                      = "${random_string.prefix.result}-was-${count.index}"
  machine_type              = "${var.gcp_inst_type_n1-std[1]}"
  zone                      = "${element(var.zone1,count.index)}"
  depends_on                = ["google_compute_instance.mysql-vm"]
  tags                      = ["stf", "was"]
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
      nat_ip = "${element(google_compute_address.was-ip.*.address,count.index)}"
    }
  }

  metadata {
    sshKeys = "${var.sshKeys}"
  }

  /*provisioner "file" {
    source      = "../index.html"
    destination = "~/index.html"

    connection {
      type        = "ssh"
      user        = "cheolgon_kang"
      agent       = false
      private_key = "${file("../id_rsa")}"
    }
  }

  provisioner "file" {
    source      = "../test.mp4"
    destination = "~/test.mp4"

    connection {
      type        = "ssh"
      user        = "cheolgon_kang"
      agent       = false
      private_key = "${file("../id_rsa")}"
    }
  }*/
## because of hanging, replace with an apt-get(openjdk, tomcat8)
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y openjdk-8-jdk",
      "export JAVA_HOME='/usr/lib/jvm/java-1.8.0-openjdk-amd64'",
      "sudo apt-get install -y tomcat8",
      "sudo bash -c cat > ~/environment << EOF",
      "PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'",
      "JAVA_HOME='/usr/lib/jvm/java-1.8.0-openjdk-amd64'",
      "CATALINA_HOME='/usr/share/tomcat8'",
      "CATALINA_BASE='/var/lib/tomcat8'",
      "EOF",
      "sudo cp ~/environment /etc/environment",
      "source /etc/environment",
      "sudo apt install -y software-properties-common",
      "git clone https://github.com/spring-petclinic/spring-framework-petclinic.git",
      "sed  's/localhost:3306/${google_compute_instance.mysql-vm.network_interface.0.address}:3306/' ./spring-framework-petclinic/pom.xml > ./spring-framework-petclinic/pom1.xml",
      "rm ./spring-framework-petclinic/pom.xml",
      "cp ./spring-framework-petclinic/pom1.xml ./spring-framework-petclinic/pom.xml",
      "sed '1,7d' ./spring-framework-petclinic/src/main/resources/db/mysql/initDB.sql > ./spring-framework-petclinic/src/main/resources/db/mysql/initDB1.sql",
      "rm ./spring-framework-petclinic/src/main/resources/db/mysql/initDB.sql",
      "cp ./spring-framework-petclinic/src/main/resources/db/mysql/initDB1.sql  ./spring-framework-petclinic/src/main/resources/db/mysql/initDB.sql",
      "cd spring-framework-petclinic",
      "./mvnw install -P MySQL -Dmaven.test.skip=true",
      "sudo cp ~/spring-framework-petclinic/target/petclinic.war /var/lib/tomcat8/webapps",
      "sudo sed '94d' /etc/tomcat8/server.xml > ~/server1.xml",
      "sudo sed '95d' ~/server1.xml > ~/server2.xml",
      "sudo rm /etc/tomcat8/server.xml",
      "sudo cp ~/server2.xml /etc/tomcat8/server.xml",
      /*"sudo rm /var/lib/tomcat8/webapps/ROOT/index.html",
      "sudo cp ~/index.html /var/lib/tomcat8/webapps/ROOT/index.html",
      "sudo cp ~/test.mp4 /var/lib/tomcat8/webapps/ROOT/test.mp4",
      "sudo /etc/init.d/tomcat8 restart",*/
      "sudo service tomcat8 restart",
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

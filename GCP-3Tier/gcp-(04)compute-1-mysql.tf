resource "google_compute_address" "mysql-ip" {
  name   = "${random_string.prefix.result}-mysql-ip-${var.gcp_regions[0]}"
  region = "${var.gcp_regions[0]}"
}

resource "google_compute_disk" "sql-data" {
  name = "sql-disk"
  type = "pd-ssd"
  zone = "${data.google_compute_zones.zones.0.names[0]}"

  labels {
    environment = "dev"
  }
}

resource "google_compute_instance" "mysql-vm" {
  name                      = "${random_string.prefix.result}-mysql"
  machine_type              = "${var.gcp_inst_type_n1-std[1]}"
  zone                      = "${data.google_compute_zones.zones.0.names[0]}"
  tags                      = ["stf", "db", "test"]
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

  attached_disk {
    source = "${google_compute_disk.sql-data.name}"
    mode   = "READ_WRITE"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.gcp-prod-subnets.0.name}"

    access_config {
      # Static IP
      nat_ip = "${google_compute_address.mysql-ip.address}"
    }
  }

  metadata {
    sshKeys = "${var.sshKeys}"
  }
  provisioner "file" {
    source      = "../alias"
    destination = "~/alias"

    connection {
      type        = "ssh"
      user        = "cheolgon_kang"
      agent       = false
      private_key = "${file("../id_rsa")}"
    }
  }
  provisioner "file" {
    source      = "../usr.sbin.mysqld"
    destination = "~/usr.sbin.mysqld"

    connection {
      type        = "ssh"
      user        = "cheolgon_kang"
      agent       = false
      private_key = "${file("../id_rsa")}"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y debconf-utils",
      "echo -e 'o\nn\np\n1\n\n\nw' | sudo fdisk /dev/sdb",
      "sudo mkfs.ext4 /dev/sdb1",
      "uuid=$(sudo blkid | grep sdb1 | cut -d '=' -f 2 | cut -d ' ' -f 1 | cut -c 2- | cut -c -36)",
      "echo UUID=$uuid /data ext4 defaults 0 0 > ~/uuid",
      "sudo chmod 666 /etc/fstab",
      "cat ~/uuid >> /etc/fstab",
      "sudo chmod 644 /etc/fstab",
      "sudo mkdir /data",
      "sudo mount -a",

      "sudo bash -c cat > ~/test.sql << EOF",
      "GRANT ALL PRIVILEGES ON *.* to 'root'@'%' IDENTIFIED BY 'petclinic';",
      "CREATE DATABASE petclinic;",
      "flush privileges;",
      "EOF",
      "echo 'mysql-server-5.7 mysql-server/root_password password petclinic' | sudo debconf-set-selections",
      "echo 'mysql-server-5.7 mysql-server/root_password_again password petclinic' | sudo debconf-set-selections",
      "sudo apt-get install -y mysql-server-5.7",

      "mysql -u root -ppetclinic < ~/test.sql",
      "sudo service mysql restart",
      "sudo bash -c cat > ~/mysqld.cnf << EOF",
      "[mysqld_safe]",
      "socket          = /var/run/mysqld/mysqld.sock",
      "nice            = 0",
      "[mysqld]",
      "user            = mysql",
      "pid-file        = /var/run/mysqld/mysqld.pid",
      "socket          = /var/run/mysqld/mysqld.sock",
      "port            = 3306",
      "basedir         = /usr",
      "datadir         = /data/mysql",
      "tmpdir          = /tmp",
      "lc-messages-dir = /usr/share/mysql",
      "skip-external-locking",
      "key_buffer_size         = 16M",
      "max_allowed_packet      = 16M",
      "thread_stack            = 192K",
      "thread_cache_size       = 8",
      "myisam-recover-options  = BACKUP",
      "query_cache_limit       = 1M",
      "query_cache_size        = 16M",
      "log_error = /var/log/mysql/error.log",
      "expire_logs_days        = 10",
      "max_binlog_size   = 100M",
      "EOF",
      "/etc/init.d/mysqld stop",
      "sudo rm /etc/mysql/mysql.conf.d/mysqld.cnf",
      "sudo cp ~/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf",
      "sudo rm /etc/apparmor.d/usr.sbin.mysqld",
      "sudo cp ~/usr.sbin.mysqld /etc/apparmor.d/usr.sbin.mysqld",
      "sudo chmod 644 /etc/apparmor.d/usr.sbin.mysqld",
      "sudo rm /etc/apparmor.d/tunables/alias",
      "sudo cp ~/alias /etc/apparmor.d/tunables/alias",
      "sudo chmod 644 /etc/apparmor.d/tunables/alias",
      "sudo rsync -av /var/lib/mysql /data/",
      "sudo chown -R mysql:mysql /data/mysql",
      "/etc/init.d/mysqld start",
      "sudo systemctl restart apparmor",
      "sudo service mysql restart",
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


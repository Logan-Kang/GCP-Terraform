resource "google_compute_snapshot" "web" {
  count       = "${var.count}"
  name        = "${random_string.prefix.result}-web-snapshot-${count.index}-${var.gcp_regions[count.index]}"
  source_disk = "${element(google_compute_instance.web-vm.*.name,count.index)}"
  zone        = "${element(var.zone1,count.index)}"
  depends_on  = ["google_compute_instance.natgw"]
}

resource "google_compute_disk" "web" {
  count      = "${var.count}"
  name       = "${random_string.prefix.result}-web-disk-${count.index}-${var.gcp_regions[count.index]}"
  type       = "pd-ssd"
  zone       = "${element(var.zone1,count.index)}"
  snapshot   = "${element(google_compute_snapshot.web.*.name,count.index)}"
  depends_on = ["google_compute_snapshot.web"]
}

resource "google_compute_image" "web" {
  count       = "${var.count}"
  name        = "${random_string.prefix.result}-web-image-${count.index}-${var.gcp_regions[count.index]}"
  source_disk = "https://www.googleapis.com/compute/v1/projects/${var.gcp_project_id}/zones/${element(var.zone1,count.index)}/disks/${element(google_compute_disk.web.*.name,count.index)}"

  #  depends_on = [ "google_compute_snapshot.default"]
  depends_on = ["google_compute_disk.web"]
}

resource "google_compute_instance_template" "web" {
  count       = "${var.count}"
  name        = "${random_string.prefix.result}-web-template-${count.index}-${var.gcp_regions[count.index]}"
  description = "This template is used to create web0 server instances."
  region      = "${element(var.gcp_regions,count.index)}"
  tags        = ["stf", "web-prod"]

  depends_on = ["google_compute_image.web"]

  service_account {
    scopes = ["logging-write"]
  }

  instance_description = "description assigned to instances"
  machine_type         = "${var.gcp_inst_type_n1-std[1]}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"

    #    preemptible = true
  }

  // Use an existing disk resource
  disk {
    #source_image = "${element(google_compute_image.web.*.name,count.index)}"
    source_image = "https://www.googleapis.com/compute/v1/projects/${var.gcp_project_id}/global/images/${element(google_compute_image.web.*.name,count.index)}"
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
  }

  network_interface {
    subnetwork = "${element(google_compute_subnetwork.gcp-prod-subnets.*.name,count.index)}"
  }

  metadata {
    sshKeys = "${var.sshKeys}"
  }
}

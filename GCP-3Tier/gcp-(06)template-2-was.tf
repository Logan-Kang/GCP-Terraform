resource "google_compute_snapshot" "was" {
  count       = "${var.count}"
  name        = "${random_string.prefix.result}-was-snapshot-${count.index}-${var.gcp_regions[count.index]}"
  source_disk = "${element(google_compute_instance.was-vm.*.name,count.index)}"
  zone        = "${element(var.zone1,count.index)}"
  depends_on  = ["google_compute_instance.natgw"]
}

resource "google_compute_disk" "was" {
  count      = "${var.count}"
  name       = "${random_string.prefix.result}-was-disk-${count.index}-${var.gcp_regions[count.index]}"
  type       = "pd-ssd"
  zone       = "${element(var.zone1,count.index)}"
  snapshot   = "${element(google_compute_snapshot.was.*.name,count.index)}"
  depends_on = ["google_compute_snapshot.was"]
}

resource "google_compute_image" "was" {
  count       = "${var.count}"
  name        = "${random_string.prefix.result}-was-image-${count.index}-${var.gcp_regions[count.index]}"
  source_disk = "https://www.googleapis.com/compute/v1/projects/${var.gcp_project_id}/zones/${element(var.zone1,count.index)}/disks/${element(google_compute_disk.was.*.name,count.index)}"

  #  depends_on = [ "google_compute_snapshot.default"]
  depends_on = ["google_compute_disk.was"]
}

resource "google_compute_instance_template" "was" {
  count       = "${var.count}"
  name        = "${random_string.prefix.result}-was-template-${count.index}-${var.gcp_regions[count.index]}"
  description = "This template is used to create was server instances."
  region      = "${element(var.gcp_regions,count.index)}"
  tags        = ["stf", "was-prod"]

  service_account {
    scopes = ["logging-write"]
  }

  depends_on = ["google_compute_image.was"]

  instance_description = "description assigned to instances"
  machine_type         = "${var.gcp_inst_type_n1-std[1]}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"

    #  preemptible = true
  }

  // Use an existing disk resource
  disk {
    #source_image = "${element(google_compute_image.was.*.name,count.index)}"
    source_image = "https://www.googleapis.com/compute/v1/projects/${var.gcp_project_id}/global/images/${element(google_compute_image.was.*.name,count.index)}"
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
  }

  network_interface {
    #    network = "${google_compute_network.gcp-network.name}"
    subnetwork = "${element(google_compute_subnetwork.gcp-prod-subnets.*.name,count.index)}"
  }

  metadata {
    sshKeys = "${var.sshKeys}"
  }
}

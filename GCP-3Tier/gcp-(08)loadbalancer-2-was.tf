resource "google_compute_forwarding_rule" "was-rule" {
  count                 = "${var.count}"
  name                  = "${random_string.prefix.result}-was-rule-${count.index}-${var.gcp_regions[count.index]}"
  ip_address            = "${element(var.inernal_lb_addresses,count.index)}"
  backend_service       = "${element(google_compute_region_backend_service.was.*.self_link,count.index)}"
  ports                 = ["8009"]
  load_balancing_scheme = "INTERNAL"
  depends_on            = ["google_compute_region_backend_service.was"]
  network               = "${google_compute_network.gcp-prod-network.self_link}"
  subnetwork            = "${element(google_compute_subnetwork.gcp-prod-subnets.*.self_link,count.index)}"
  region                = "${element(var.gcp_regions,count.index)}"
}

resource "google_compute_region_backend_service" "was" {
  count            = "${var.count}"
  name             = "${random_string.prefix.result}-was-backend-${count.index}-${var.gcp_regions[count.index]}"
  description      = "Our company was site"
  protocol         = "TCP"
  timeout_sec      = 10
  session_affinity = "CLIENT_IP"
  region           = "${element(var.gcp_regions,count.index)}"

  backend {
    group = "${element(google_compute_region_instance_group_manager.was.*.instance_group,count.index)}"
  }

  health_checks = ["${google_compute_health_check.was.self_link}"]
}

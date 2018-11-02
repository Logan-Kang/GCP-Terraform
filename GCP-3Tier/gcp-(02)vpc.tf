resource "google_compute_network" "gcp-prod-network" {
  name                    = "${random_string.prefix.result}-gcp-prod-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "gcp-prod-subnets" {
  name                     = "${random_string.prefix.result}-gcp-prod-subnet-${count.index}-${var.gcp_regions[count.index]}"
  count                    = "${var.count}"
  ip_cidr_range            = "${element(var.gcp_network_prod_cidrs,count.index)}"
  network                  = "${google_compute_network.gcp-prod-network.name}"
  region                   = "${element(var.gcp_regions,count.index)}"
  private_ip_google_access = "true"
  enable_flow_logs         = true
}
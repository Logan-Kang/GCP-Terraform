data "google_compute_zones" "zones" {
  count  = "${length(var.gcp_regions)}"
  region = "${element(var.gcp_regions,count.index)}"
}

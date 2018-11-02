resource "google_compute_region_instance_group_manager" "was" {
  count              = "${var.count}"
  name               = "${random_string.prefix.result}-was-instange-group-${count.index}-${var.gcp_regions[count.index]}"
  instance_template  = "${element(google_compute_instance_template.was.*.self_link,count.index)}"
  base_instance_name = "${random_string.prefix.result}-prod-was-${count.index}-${var.gcp_regions[count.index]}"

  distribution_policy_zones = ["${element(var.zone1,count.index)}", "${element(var.zone3,count.index)}"]
  region                    = "${element(var.gcp_regions,count.index)}"

  target_size = "2"

  auto_healing_policies {
    health_check      = "${element(google_compute_health_check.was.*.self_link,count.index)}"
    initial_delay_sec = 300
  }

  named_port {
    name = "was"
    port = 8009
  }

  update_strategy = "ROLLING_UPDATE"

  rolling_update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
    min_ready_sec         = 120
  }
}

resource "google_compute_region_autoscaler" "was" {
  count  = "${var.count}"
  name   = "${random_string.prefix.result}-was-scaler-${count.index}-${var.gcp_regions[count.index]}"
  region = "${element(var.gcp_regions,count.index)}"
  target = "${element(google_compute_region_instance_group_manager.was.*.self_link,count.index)}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

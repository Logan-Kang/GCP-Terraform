resource "google_compute_region_instance_group_manager" "web" {
  count              = "${var.count}"
  name               = "${random_string.prefix.result}-web-instange-group-${count.index}-${var.gcp_regions[count.index]}"
  instance_template  = "${element(google_compute_instance_template.web.*.self_link,count.index)}"
  base_instance_name = "${random_string.prefix.result}-prod-web-${count.index}-${var.gcp_regions[count.index]}"

  distribution_policy_zones = ["${element(var.zone1,count.index)}", "${element(var.zone3,count.index)}"]
  region                    = "${element(var.gcp_regions,count.index)}"

  target_size = "2"

  auto_healing_policies {
    health_check      = "${google_compute_health_check.web.self_link}"
    initial_delay_sec = 300
  }

  named_port {
    name = "http"
    port = 80
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

# 원래 버젼에서 region 추가됨
resource "google_compute_target_pool" "web" {
  count = "${var.count}"

  name = "${random_string.prefix.result}-web-pool-${count.index}-${var.gcp_regions[count.index]}"
  region = "${element(var.gcp_regions,count.index)}"

  health_checks = [
    "${google_compute_http_health_check.web.name}",
  ]
}

resource "google_compute_region_autoscaler" "web" {
  count = "${var.count}"

  name   = "${random_string.prefix.result}-web-scaler-${count.index}-${var.gcp_regions[count.index]}"
  region = "${element(var.gcp_regions,count.index)}"
  target = "${element(google_compute_region_instance_group_manager.web.*.self_link,count.index)}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

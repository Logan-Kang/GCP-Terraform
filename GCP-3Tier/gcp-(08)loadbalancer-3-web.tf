resource "google_compute_target_http_proxy" "web" {
  name        = "${random_string.prefix.result}-web-proxy"
  description = "a description"
  url_map     = "${google_compute_url_map.web.self_link}"
}

resource "google_compute_url_map" "web" {
  name            = "${random_string.prefix.result}-web-map"
  description     = "a description"
  default_service = "${google_compute_backend_service.website.self_link}"
}

resource "google_compute_global_forwarding_rule" "web-rule" {
  name       = "${random_string.prefix.result}-web-rule"
  target     = "${google_compute_target_http_proxy.web.self_link}"
  port_range = "80"
  ip_address = "${google_compute_global_address.web.address}"
  depends_on = ["google_compute_backend_service.website"]
}

resource "google_compute_backend_service" "website" {
  #  count       = "${var.count}"
  name        = "${random_string.prefix.result}-web-backend"
  description = "Our company website"
  port_name   = "http"
  protocol    = "HTTP"
  health_checks = ["${google_compute_http_health_check.web.self_link}"]
  timeout_sec = 10
  enable_cdn  = true

  backend {
    group           = "${google_compute_region_instance_group_manager.web.0.instance_group}"
    capacity_scaler = 1
    balancing_mode  = "UTILIZATION"
  }
/*
  backend {
    group           = "${google_compute_region_instance_group_manager.web.1.instance_group}"
    capacity_scaler = 1
    balancing_mode  = "UTILIZATION"
  }

  backend {
    group           = "${google_compute_region_instance_group_manager.web.2.instance_group}"
    capacity_scaler = 1
    balancing_mode  = "UTILIZATION"
  }

  backend {
    group           = "${google_compute_region_instance_group_manager.web.3.instance_group}"
    capacity_scaler = 1
    balancing_mode  = "UTILIZATION"
  }

  backend {
    group           = "${google_compute_region_instance_group_manager.web.4.instance_group}"
    capacity_scaler = 1
    balancing_mode  = "UTILIZATION"
  }

  /*
                              backend {
                                group           = "${google_compute_region_instance_group_manager.web.3.instance_group}"
                                capacity_scaler = 1
                                balancing_mode  = "UTILIZATION"
                              }

                              backend {
                                group           = "${google_compute_region_instance_group_manager.web.4.instance_group}"
                                capacity_scaler = 1
                                balancing_mode  = "UTILIZATION"
                              }
                              backend {
                                group           = "${google_compute_region_instance_group_manager.web.5.instance_group}"
                                capacity_scaler = 1
                                balancing_mode  = "UTILIZATION"
                              }
                              backend {
                                group           = "${google_compute_region_instance_group_manager.web.6.instance_group}"
                                capacity_scaler = 1
                                balancing_mode  = "UTILIZATION"
                              }
                              backend {
                                group           = "${google_compute_region_instance_group_manager.web.7.instance_group}"
                                capacity_scaler = 1
                                balancing_mode  = "UTILIZATION"
                              }
                              backend {
                                group           = "${google_compute_region_instance_group_manager.web.8.instance_group}"
                                capacity_scaler = 1
                                balancing_mode  = "UTILIZATION"
                              }
                              backend {
                                group           = "${google_compute_region_instance_group_manager.web.9.instance_group}"
                                capacity_scaler = 1
                                balancing_mode  = "UTILIZATION"
                              }
                              */

}

resource "google_compute_global_address" "web" {
  name = "${random_string.prefix.result}-web-global-ip"
}

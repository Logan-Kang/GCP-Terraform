resource "google_compute_target_https_proxy" "ssl" {
  name             = "${random_string.prefix.result}-https-proxy"
  url_map          = "${google_compute_url_map.https.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.default.self_link}"]
}

resource "google_compute_global_forwarding_rule" "ssl" {
  name       = "${random_string.prefix.result}-ssl-rule"
  target     = "${google_compute_target_https_proxy.ssl.self_link}"
  port_range = "443"
  ip_address = "${google_compute_global_address.web.address}"
  depends_on = ["google_compute_backend_service.https"]
}

resource "google_compute_url_map" "https" {
  name            = "${random_string.prefix.result}-https-map"
  description     = "a description"
  default_service = "${google_compute_backend_service.https.self_link}"
}

resource "google_compute_ssl_certificate" "default" {
  name        = "my-certificate"
  description = "a description"
  private_key = "${file("../cert.key")}"
  certificate = "${file("../cert.crt")}"
}

resource "google_compute_backend_service" "https" {
  name          = "https-backend"
  port_name     = "http"
  protocol      = "HTTP"
  health_checks = ["${google_compute_health_check.web.self_link}"]
  enable_cdn    = true

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
  */
}

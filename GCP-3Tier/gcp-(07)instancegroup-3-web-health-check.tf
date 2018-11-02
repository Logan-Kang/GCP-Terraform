resource "google_compute_health_check" "web" {
  name               = "${random_string.prefix.result}-web-health-check"
  timeout_sec        = 1
  check_interval_sec = 10

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_http_health_check" "web" {
  name                = "${random_string.prefix.result}-web-http-health-check"
  description         = "Basic HTTP health check to monitor NGINX instances"
  request_path        = "/"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 10
}

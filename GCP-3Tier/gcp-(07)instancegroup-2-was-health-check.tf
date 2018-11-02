resource "google_compute_health_check" "was" {
  name               = "${random_string.prefix.result}-was-health-check"
  timeout_sec        = 1
  check_interval_sec = 10

  tcp_health_check {
    port = "8009"
  }
}

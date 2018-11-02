provider "google" {
  credentials = "../kcgowner-vdcesa.json"
  project     = "${var.gcp_project_id}"
}
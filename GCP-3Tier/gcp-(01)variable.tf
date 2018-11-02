###### Region

variable count {
  default = 1
}

variable "gcp_project_id" {
  default = "vdcesa-poc"
}
variable "gcp_regions" {
  type = "list"

  default = [
    "asia-northeast1",
    "asia-southeast1",
    "us-east4",
    "australia-southeast1",
    "europe-west2",
    "europe-west3",
    "southamerica-east1",
    "asia-south1",
    "northamerica-northeast1",
    "europe-west4",
    "us-central1",
    "europe-west1",
    "us-west1",
    "asia-east1",
    "us-east1",
  ]
}

variable "zone1" {
  type = "list"

  default = [
    "asia-northeast1-a",
    "asia-southeast1-a",
    "us-east4-a",
    "australia-southeast1-a",
    "europe-west2-a",
    "europe-west3-a",
    "southamerica-east1-a",
    "asia-south1-a",
    "northamerica-northeast1-a",
    "europe-west4-a",
    "us-central1-a",
    "europe-west1-b",
    "us-west1-a",
    "asia-east1-a",
    "us-east1-b",
  ]
}

variable "zone2" {
  type = "list"

  default = [
    "asia-northeast1-b",
    "asia-southeast1-b",
    "us-east4-b",
    "australia-southeast1-b",
    "europe-west2-b",
    "europe-west3-b",
    "southamerica-east1-b",
    "asia-south1-b",
    "northamerica-northeast1-b",
    "europe-west4-b",
    "us-central1-b",
    "europe-west1-c",
    "us-west1-b",
    "asia-east1-b",
    "us-east1-c",
  ]
}

variable "zone3" {
  type = "list"

  default = [
    "asia-northeast1-c",
    "asia-southeast1-c",
    "us-east4-c",
    "australia-southeast1-c",
    "europe-west2-c",
    "europe-west3-c",
    "southamerica-east1-c",
    "asia-south1-c",
    "northamerica-northeast1-c",
    "europe-west4-c",
    "us-central1-c",
    "europe-west1-d",
    "us-west1-c",
    "asia-east1-c",
    "us-east1-d",
  ]
}

variable "subnet" {
  type = "map"

  default = {
    "asia-northeast1"         = "10.146.0.0/20"
    "asia-southeast1"         = "10.148.0.0/20"
    "us-east4"                = "10.150.0.0/20"
    "australia-southeast1"    = "10.152.0.0/20"
    "europe-west2"            = "10.154.0.0/20"
    "europe-west3"            = "10.156.0.0/20"
    "southamerica-east1"      = "10.158.0.0/20"
    "asia-south1"             = "10.160.0.0/20"
    "northamerica-northeast1" = "10.162.0.0/20"
    "europe-west4"            = "10.164.0.0/20"
    "us-central1"             = "10.128.0.0/20"
    "europe-west1"            = "10.132.0.0/20"
    "us-west1"                = "10.138.0.0/20"
    "asia-east1"              = "10.140.0.0/20"
    "us-east1"                = "10.142.0.0/20"
  }
}

variable gcp_inst_type_n1-std {
  type        = "list"
  description = "Machine Type. Correlates to an network egress cap."

  default = [
    "n1-standard-1",
    "n1-standard-2",
    "n1-standard-4",
    "n1-standard-8",
  ]
}

variable gcp_disk_img_ubnt_1604 {
  description = "Boot disk for gcp_instance_type."
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
}

variable gcp_network_prod_cidrs {
  type = "list"

  default = [
    "172.16.0.0/24",
    "172.16.1.0/24",
    "172.16.2.0/24",
    "172.16.3.0/24",
    "172.16.4.0/24",
    "172.16.5.0/24",
    "172.16.6.0/24",
    "172.16.7.0/24",
    "172.16.8.0/24",
    "172.16.9.0/24",
    "172.16.10.0/24",
    "172.16.11.0/24",
    "172.16.12.0/24",
    "172.16.13.0/24",
    "172.16.14.0/24",
  ]
}

variable inernal_lb_addresses {
  description = "Private IP address for GCP VM instance."
  type        = "list"

  default = [
    "172.16.0.200",
    "172.16.1.200",
    "172.16.2.200",
    "172.16.3.200",
    "172.16.4.200",
    "172.16.5.200",
    "172.16.6.200",
    "172.16.7.200",
    "172.16.8.200",
    "172.16.9.200",
    "172.16.10.200",
    "172.16.11.200",
    "172.16.12.200",
    "172.16.13.200",
    "172.16.14.200",
  ]
}

variable gcp_vm_address {
  description = "Private IP address for GCP VM instance."
  default     = "172.16.0.100"
}

resource "random_string" "prefix" {
  length  = 2
  special = false
  upper   = false
  number  = false
}

variable sshKeys {
  default = "cheolgon_kang:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7fVHwMpf6PrdUqa8Ur0P0Of5c0KxLGmA59nu4HPcrNcZfetyDnV9/RxP5DE6A3M9qCdbL5/4dQYoX88lKdtcyFn5wXIUXME+HewpY9PUSXUzLmaGmGL43tdLqb98dxMqKv4zGIPRVrcOsX0XtftjgWZiD9YI84ipaFRaFoQ6UvH8zld30yMmesKD/jmDMM92q4zZxIpvzT3IEdzptWfhTputO6tLUj1xIfsEbETGq4UaxNwSbJ0/w1sfh4U5LsIgBjDOGh6RmSmFvHqUQxcmR00e8JMm+jmFtudHDyMDo1lYgKJEcLchbY0MRxdSzW5hWVFRXXlGnGjc3AF1Z5a2B cheolgon_kang@CGKang"
}

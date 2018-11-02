# 간략한 bucket 생성
resource "google_storage_bucket" "image-store" {
  name     = "image-store-bucket-asdf"
  location = "ASIA-NORTHEAST1"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

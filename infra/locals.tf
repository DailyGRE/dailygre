locals {
  cloud_functions = {
    "hello-world" = {
      ingress_settings = "ALLOW_ALL"
    }
    "st1-news-extraction" = {}
  }
}

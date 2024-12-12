locals {
  cloud_functions = { for k, v in {
    hello-world = {
      ingress_settings = "ALLOW_ALL"
    }
  }: k => v
    if length(fileset("../functions/${k}", "*")) > 0 }
}

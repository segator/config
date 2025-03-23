# stupid filter not seems to work.. unsupported block type.. even is documented that works..
# data "cloudflare_zone" "zones" {
#   filter {
#     name = var.cloudflare_zone_name
#   }
# }

data "cloudflare_zone" "zone" {
  zone_id = var.cloudflare_zone_id
}

locals {
  base_domain = "${var.cluster_name}.${data.cloudflare_zone.zone.name}"
}

resource "cloudflare_dns_record" "wildcard_oke" {
  zone_id = var.cloudflare_zone_id
  #zone_id  = "349234"
  comment = "Load balancer for ${var.cluster_name}"
  content = local.nlb_public_ip
  name    = "*.${local.base_domain}"
  proxied = false
  ttl     = 300
  type    = "A"
}
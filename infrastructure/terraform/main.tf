data "digitalocean_region" "do" {
  slug = "ams3"
}

data "digitalocean_vpc" "do" {
  name = "k8s"
}

resource "digitalocean_loadbalancer" "do" {
  name = "ingress"
  region = data.digitalocean_region.do.slug
  size = "lb-small"
  size_unit = 1

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }
  lifecycle {
    ignore_changes = [
      forwarding_rule,
      name
    ]
  }
}

resource "digitalocean_domain" "do" {
  name = "do.nullkarma.com"
  ip_address = digitalocean_loadbalancer.do.ip
}

resource "digitalocean_record" "argocd" {
  domain = digitalocean_domain.do.name
  name   = "*"
  type   = "A"
  ttl = 30
  value  = digitalocean_loadbalancer.do.ip
}

resource "digitalocean_kubernetes_cluster" "do" {
  name    = "k8s"
  region  = data.digitalocean_region.do.slug
  version = "1.29.1-do.0"
  vpc_uuid = data.digitalocean_vpc.do.id
  node_pool {
    name = "default"
    size = "s-4vcpu-8gb"
    auto_scale = true
    min_nodes = 3
    max_nodes = 5
  }
}

output "loadbalancer_id" {
  value = digitalocean_loadbalancer.do.id
}

resource "local_file" "loadbalancer_id" {
  filename = "ytt.data.yaml"
  content = templatefile("ytt.yaml", {
    loadbalancer_id = digitalocean_loadbalancer.do.id
  })
}
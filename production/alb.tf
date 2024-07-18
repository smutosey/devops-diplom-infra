# Создание группы бэкендов
resource "yandex_alb_backend_group" "alb-bg" {
  name = "alb-bg"

  http_backend {
    name             = "alb-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_compute_instance_group.worker.application_load_balancer[0].target_group_id]

    load_balancing_config {
      panic_threshold = 5
    }

    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/healthz"
      }
    }
  }
}

# Создание HTTP-роутера
resource "yandex_alb_http_router" "alb-router" {
  name = "alb-router"
}

resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-vhost"
  authority      = [for subdomain in var.dns_params.subdomains : "${subdomain}.${var.dns_params.domain}"]
  http_router_id = yandex_alb_http_router.alb-router.id
  route {
    name = "alb-route"
    http_route {
      http_route_action {
        auto_host_rewrite = true
        backend_group_id = yandex_alb_backend_group.alb-bg.id
        timeout          = "60s"
      }
    }
  }
}

#Создание L7-балансировщика
resource "yandex_alb_load_balancer" "alb" {
  name               = "alb"
  network_id         = yandex_vpc_network.k8s_vpc.id
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]

  allocation_policy {
    dynamic location {
      for_each = {for subnet in yandex_vpc_subnet.k8s_subnets : subnet.zone => subnet.id if subnet.name != "public"}
      content {
        zone_id   = location.key
        subnet_id = location.value
      }
    }
  }

  listener {
    name = "list-http"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.alb_addr.external_ipv4_address[0].address
        }
      }
      ports = [80]
    }
    http {
      redirects {
        http_to_https = true
      }
    }
  }

  listener {
    name = "listener-http"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.alb_addr.external_ipv4_address[0].address
        }
      }
      ports = [443]
    }
    tls {
      default_handler {
        http_handler {
          http_router_id = yandex_alb_http_router.alb-router.id
        }
        certificate_ids = [data.yandex_cm_certificate.k8s.id]
      }
      sni_handler {
        name         = "sni"
        server_names = [var.dns_params.domain]
        handler {
          http_handler {
            http_router_id = yandex_alb_http_router.alb-router.id
          }
          certificate_ids = [data.yandex_cm_certificate.k8s.id]
        }
      }
    }
  }
}

# Сертификат TLS
data "yandex_cm_certificate" "k8s" {
  certificate_id = var.dns_params.certificate_id
}

# Создание ресурсной записи в DNS-зоне
data "yandex_dns_zone" "k8s-apps" {
  dns_zone_id = var.dns_params.dns_zone_id
}

resource "yandex_dns_recordset" "k8s-domains" {
  for_each = toset(var.dns_params.subdomains)
  zone_id = data.yandex_dns_zone.k8s-apps.id
  name    = each.value
  ttl     = 600
  type    = "A"
  data    = [yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address]
}
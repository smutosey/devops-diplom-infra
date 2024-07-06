resource "yandex_vpc_network" "k8s_vpc" {
  name = var.vpc_params.name
}

resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat_route"
  network_id = yandex_vpc_network.k8s_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = cidrhost(var.vpc_params.subnets[var.instance_params["bastion"].subnet].cidr, -2)
  }
}

resource "yandex_vpc_subnet" "k8s_subnets" {
  depends_on     = [yandex_vpc_network.k8s_vpc]
  for_each       = var.vpc_params.subnets
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.k8s_vpc.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = each.value.route_nat == true ? yandex_vpc_route_table.nat_route.id : null
}


resource "yandex_vpc_address" "bastion_addr" {
  name = "BastionIP"

  external_ipv4_address {
    zone_id = yandex_vpc_subnet.k8s_subnets["public"].zone
  }
}

resource "yandex_vpc_address" "lb_addr" {
  name = "LoadbalancerIP"

  external_ipv4_address {
    zone_id = yandex_vpc_subnet.k8s_subnets["public"].zone
  }

#   provisioner "local-exec" {
#     command = "sed -i -e '/supplementary_addresses_in_ssl_keys: / s/: .*/: [${self.external_ipv4_address[0].address}]/' ./ansible/group_vars/k8s_cluster/k8s-cluster.yml"
#   }
}

resource "yandex_lb_network_load_balancer" "controllers-lb" {
  name = "controllers-lb"

  listener {
    name = "controllers-lb-listener"
    port = 6443
    external_address_spec {
      address = yandex_vpc_address.lb_addr.external_ipv4_address[0].address
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.control-plane.load_balancer.0.target_group_id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 6443
      }
    }
  }
}

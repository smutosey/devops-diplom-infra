resource "yandex_vpc_network" "k8s_vpc" {
  name = var.vpc_params.name
}

resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat_route"
  network_id = yandex_vpc_network.k8s_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   =  var.instance_params["bastion"].internal_ip
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
  name = "Bastion VM external addr"

  external_ipv4_address {
    zone_id = yandex_vpc_subnet.k8s_subnets["public"].zone
  }
}

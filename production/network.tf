# Создание виртуальной сети
resource "yandex_vpc_network" "k8s_vpc" {
  name = var.vpc_params.name
}

# Настройка роутинга исходящего трафика через NAT-инстанс
resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat_route"
  network_id = yandex_vpc_network.k8s_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = cidrhost(var.vpc_params.subnets[var.instance_params["bastion"].subnet].cidr, -2)
  }
}

# Создание подсетей
resource "yandex_vpc_subnet" "k8s_subnets" {
  depends_on     = [yandex_vpc_network.k8s_vpc]
  for_each       = var.vpc_params.subnets
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.k8s_vpc.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = each.value.route_nat == true ? yandex_vpc_route_table.nat_route.id : null
}

# Статический IP адрес для джампера
resource "yandex_vpc_address" "bastion_addr" {
  name = "BastionIP"
  external_ipv4_address {
    zone_id = yandex_vpc_subnet.k8s_subnets["public"].zone
  }
}
# Статический IP адрес для network load balancer (для мастер-нод k8s)
resource "yandex_vpc_address" "lb_addr" {
  name = "LoadbalancerIP"
  external_ipv4_address {
    zone_id = yandex_vpc_subnet.k8s_subnets["public"].zone
  }
}
# Статический IP адрес для application load balancer (для worker-нод)
resource "yandex_vpc_address" "alb_addr" {
  name = "ApplicationLoadbalancerIP"
  external_ipv4_address {
    zone_id = yandex_vpc_subnet.k8s_subnets["public"].zone
  }
}

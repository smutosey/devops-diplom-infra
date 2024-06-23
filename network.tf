resource "yandex_vpc_network" "vpc" {
  name = var.vpc_params.name
}

resource "yandex_vpc_subnet" "subnets" {
  for_each       = { for i in var.vpc_params.subnets : i.zone => i }
  name           = "${var.vpc_params.name}-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [each.value.cidr]
}
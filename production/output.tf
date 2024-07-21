# output "bastion_nat_ip" {
#   value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
# }
#
# output "lb_nat_ip" {
#   value = yandex_vpc_address.lb_addr.external_ipv4_address[0].address
# }
output "bastion_nat_ip" {
  value = yandex_compute_instance.bastion_vm.network_interface[0].nat_ip_address
}
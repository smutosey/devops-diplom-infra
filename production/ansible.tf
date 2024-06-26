resource "local_file" "ansible_inventory" {
  depends_on = [
    yandex_compute_instance_group.worker,
    yandex_compute_instance_group.control-plane,
  ]
  content = templatefile(
    "${path.module}/templates/inventory.yml.tftpl", {
      controllers = {
        for idx, v in yandex_compute_instance_group.control-plane.instances.*.fqdn : v => {
          external_ip_address = yandex_compute_instance_group.control-plane.instances[idx].network_interface.0.nat_ip_address
          internal_ip_address = yandex_compute_instance_group.control-plane.instances[idx].network_interface.0.ip_address
        }
      }
      workers = {
        for idx, v in yandex_compute_instance_group.worker.instances.*.fqdn : v => {
          external_ip_address = yandex_compute_instance_group.worker.instances[idx].network_interface.0.nat_ip_address
          internal_ip_address = yandex_compute_instance_group.worker.instances[idx].network_interface.0.ip_address
        }
      }
#       bastion = {
#         (yandex_compute_instance.bastion.fqdn) = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
#       }
    }
  )
  filename = "${path.module}/ansible/inventory.yml"
}

# resource "local_file" "ansible_inventory" {
#   depends_on = [
#     yandex_compute_instance_group.worker,
#     yandex_compute_instance_group.control-plane,
#   ]
#   content = templatefile(
#     "${path.module}/templates/inventory.yml.tftpl", {
#       bastion = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
#       controllers = [{
#         for s in yandex_compute_instance_group.control-plane.instances : s.fqdn => s.network_interface.0.ip_address
#       }]
#       workers = [{
#         for s in yandex_compute_instance_group.worker.instances : s.fqdn => s.network_interface.0.ip_address
#       }]
#     }
#   )
#   filename = "${path.module}/ansible/inventory.yml"
# }
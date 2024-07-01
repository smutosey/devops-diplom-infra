resource "local_file" "ansible_inventory" {
  depends_on = [
    yandex_compute_instance_group.worker,
    yandex_compute_instance_group.control-plane,
  ]
  content = templatefile("./templates/inventory.yml.tftpl", {
    user = var.admin
    controllers = {
      for instance in yandex_compute_instance_group.control-plane.instances :
      instance.fqdn => instance.network_interface.0.ip_address
    }
    workers = {
      for instance in yandex_compute_instance_group.worker.instances :
      instance.fqdn => instance.network_interface.0.ip_address
    }
    bastion = {
      external_ip_address = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    }
    }
  )
  filename = "./ansible/inventory.yml"
}
#
# resource "null_resource" "kill_apt_controllers" {
#   depends_on = [
#     yandex_compute_instance_group.worker,
#     yandex_compute_instance_group.control-plane,
#   ]
#   provisioner "remote-exec" {
#     inline = [
#       "sudo killall apt apt-get unattended-upgr",
#     ]
#     connection {
#       type     = "ssh"
#       user     = var.admin
#       private_key = file(var.ssh_private_key)
#       host = yandex_compute_instance_group.control-plane.instances.2.network_interface.0.ip_address
#       bastion_host = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
#     }
#   }
# }
#
# resource "null_resource" "kill_apt_workers" {
#   depends_on = [
#     yandex_compute_instance_group.worker,
#     yandex_compute_instance_group.control-plane,
#   ]
#   provisioner "remote-exec" {
#     inline = [
#       "sudo killall apt apt-get unattended-upgr",
#     ]
#     connection {
#       type     = "ssh"
#       user     = var.admin
#       private_key = file(var.ssh_private_key)
#       host = yandex_compute_instance_group.worker.instances.2.network_interface.0.ip_address
#       bastion_host = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
#     }
#   }
# }
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

resource "terraform_data" "kubespray" {
  triggers_replace = local_file.ansible_inventory.content

  provisioner "local-exec" {
    command = templatefile("./templates/kubespray-run.sh.tftpl", { lb-ip = yandex_vpc_address.lb_addr.external_ipv4_address[0].address })
  }
}
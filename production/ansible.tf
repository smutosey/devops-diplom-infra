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
    command = join(" ",
      [
        "docker run --rm -e ANSIBLE_HOST_KEY_CHECKING=0 -e ANSIBLE_FORCE_COLOR=1",
        "--mount type=bind,source=$(pwd)/ansible/,dst=/kubespray/inventory/production/",
        "--mount type=bind,source=$HOME/.ssh/,dst=/root/.ssh/",
        "quay.io/kubespray/kubespray:v2.25.0",
        "ansible-playbook cluster.yml -i /kubespray/inventory/production/inventory.yml",
        "--become --become-user=root",
        "-e '{\"supplementary_addresses_in_ssl_keys\":[\"${yandex_vpc_address.lb_addr.external_ipv4_address[0].address}\"]}'",
        "&&",
        "docker run --rm -v $(pwd)/ansible/:/production/ quay.io/kubespray/kubespray:v2.25.0",
        "sed -i -e 's# https://.*# https://${yandex_vpc_address.lb_addr.external_ipv4_address[0].address}:6443#'",
        "/production/artifacts/admin.conf",
    ])
  }
}
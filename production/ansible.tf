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

# resource "terraform_data" "kubespray" {
#   triggers_replace = local_file.ansible_inventory.content
#
#   provisioner "local-exec" {
#     command = templatefile("./templates/kubespray-run.sh.tftpl", { lb-ip = yandex_vpc_address.lb_addr.external_ipv4_address[0].address })
#   }
# }
#
# resource "terraform_data" "atlantis-helm" {
# #   triggers_replace = local_file.ansible_inventory.content
#   depends_on       = [terraform_data.kubespray]
#
#   provisioner "local-exec" {
#     environment = {
#       GITHUB_SECRET = var.github_secret
#       GITHUB_TOKEN  = var.github_token
#       BACKEND_KEY = var.access_key
#       BACKEND_SECRET = var.secret_key
#       CLOUD_ID = var.cloud_id
#       FOLDER_ID = var.folder_id
#       SSH_CERT = var.ssh_public_key_b64
#       SSH_KEY = var.ssh_private_key_b64
#       SA_KEY = var.sa_key_b64
#
#     }
#     command = join(" ",
#       [
#         "helm upgrade --install --atomic atlantis runatlantis/atlantis",
#         "--set github.secret=$GITHUB_SECRET",
#         "--set github.token=$GITHUB_TOKEN",
#         "--set environment.AWS_ACCESS_KEY_ID=$BACKEND_KEY",
#         "--set environment.AWS_SECRET_ACCESS_KEY=$BACKEND_SECRET",
#         "--set environment.TF_VAR_cloud_id=$CLOUD_ID",
#         "--set environment.TF_VAR_folder_id=$FOLDER_ID",
#         "--set environment.TF_VAR_ssh_public_key_b64=$SSH_CERT",
#         "--set environment.TF_VAR_ssh_private_key_b64=$SSH_KEY",
#         "--set environment.TF_VAR_sa_key_b64=$SA_KEY",
#         "-f helm/atlantis.yaml",
#         "--create-namespace -n atlantis",
#       ]
#     )
#   }
# }
#
# ######### Отключено, т.к. деплоим теперь через github actions
# resource "terraform_data" "monitoring-helm" {
#   triggers_replace = local_file.ansible_inventory.content
#   depends_on       = [terraform_data.kubespray]
#
#   provisioner "local-exec" {
#     command = "helm upgrade --install --atomic kube-prom-stack prometheus-community/kube-prometheus-stack -f helm/kube-prom-stack.yaml --create-namespace -n monitoring"
#   }
# }
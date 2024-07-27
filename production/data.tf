# Сервисный аккаунт в каталоге YC для развертывания
data "yandex_iam_service_account" "terraform" {
  name = var.service_account
}

# Образы для создания ВМ кластера
data "yandex_compute_image" "vm_images" {
  for_each = var.instance_params
  family   = each.value.image_family
}

# cloud-init
data "template_file" "cloudinit" {
  template = file("./templates/cloud-init.yml")
  vars = {
    username       = var.admin
    ssh_public_key = base64decode(var.ssh_public_key_b64)
    packages       = jsonencode(var.vm_packages)
  }
}

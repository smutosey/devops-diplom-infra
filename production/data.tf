data "yandex_iam_service_account" "terraform" {
  name = "terraform-sa"
}

data "yandex_compute_image" "masters_image" {
  family = var.masters_params.image_family
}

data "yandex_compute_image" "workers_image" {
  family = var.workers_params.image_family
}

data "yandex_compute_image" "nat_image" {
  family   = var.nat_vm_params.image_family
}

data "yandex_compute_image" "bastion_image" {
  family   = var.bastion_vm_params.image_family
}

data "template_file" "web_cloudinit" {
  template = file("./templates/cloud-init.yml")
  vars = {
    username       = var.admin
    ssh_public_key = file(var.ssh_public_key)
    packages       = jsonencode(var.vm_packages)
  }
}

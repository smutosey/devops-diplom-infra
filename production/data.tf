data "yandex_iam_service_account" "terraform" {
  name = "terraform-sa"
}

data "yandex_compute_image" "vm_images" {
  for_each = var.instance_params
  family   = each.value.image_family
}

data "template_file" "web_cloudinit" {
  template = file("./templates/cloud-init.yml")
  vars = {
    username       = var.admin
    ssh_public_key = file(var.ssh_public_key)
    packages       = jsonencode(var.vm_packages)
  }
}

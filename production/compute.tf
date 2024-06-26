resource "yandex_compute_instance" "bastion" {
  name        = var.instance_params["bastion"].vm_name
  hostname    = var.instance_params["bastion"].vm_name
  platform_id = var.instance_params["bastion"].platform
  zone        = yandex_vpc_subnet.k8s_subnets[var.instance_params["bastion"].subnet].zone
  allow_stopping_for_update = true

  resources {
    cores  = var.instance_params["bastion"].instance_cores
    memory = var.instance_params["bastion"].instance_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_images["bastion"].id
      size     = var.instance_params["bastion"].disk_size
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.k8s_subnets[var.instance_params["bastion"].subnet].id
    nat        = var.instance_params["bastion"].public_ip
    nat_ip_address = yandex_vpc_address.bastion_addr.external_ipv4_address[0].address
    ip_address = cidrhost(var.vpc_params.subnets[var.instance_params["bastion"].subnet].cidr, -2)
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id]
  }

  scheduling_policy {
    preemptible = var.instance_params["bastion"].preemptible
  }

  metadata = {
    user-data          = data.template_file.web_cloudinit.rendered
  }
}

resource "yandex_compute_instance_group" "control-plane" {
  depends_on         = [yandex_vpc_subnet.k8s_subnets]
  name               = var.instance_params["masters"].group_name
  folder_id          = var.folder_id
  service_account_id = data.yandex_iam_service_account.terraform.id
  instance_template {
    platform_id = var.instance_params["masters"].platform
    name        = "${var.instance_params["masters"].vm_name}-{instance.index}"
    resources {
      memory        = var.instance_params["masters"].instance_memory
      cores         = var.instance_params["masters"].instance_cores
      core_fraction = var.instance_params["masters"].core_fraction
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.vm_images["masters"].id
        size     = var.instance_params["masters"].disk_size
      }
    }

    network_interface {
      network_id = yandex_vpc_network.k8s_vpc.id
      subnet_ids = [for key, value in yandex_vpc_subnet.k8s_subnets : value.id if value.name != "public"]
      nat        = var.instance_params["masters"].public_ip
      security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    }

    scheduling_policy {
      preemptible = var.instance_params["masters"].preemptible
    }

    metadata = {
      user-data          = data.template_file.web_cloudinit.rendered
      serial-port-enable = 1
    }
  }

  scale_policy {
    fixed_scale {
      size = var.instance_params["masters"].group_size
    }
  }

  allocation_policy {
    zones = [for key, value in yandex_vpc_subnet.k8s_subnets : value.zone if value.name != "public"]
  }

  deploy_policy {
    max_unavailable = var.instance_params["masters"].max_unavailable
    max_expansion   = var.instance_params["masters"].max_expansion
    max_creating    = var.instance_params["masters"].max_creating
    max_deleting    = var.instance_params["masters"].max_deleting
  }
}

resource "yandex_compute_instance_group" "worker" {
  depends_on         = [yandex_vpc_subnet.k8s_subnets]
  name               = var.instance_params["workers"].group_name
  folder_id          = var.folder_id
  service_account_id = data.yandex_iam_service_account.terraform.id
  instance_template {
    platform_id = var.instance_params["workers"].platform
    name        = "${var.instance_params["workers"].vm_name}-{instance.index}"
    resources {
      memory        = var.instance_params["workers"].instance_memory
      cores         = var.instance_params["workers"].instance_cores
      core_fraction = var.instance_params["workers"].core_fraction
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.vm_images["workers"].id
        size     = var.instance_params["workers"].disk_size
      }
    }

    network_interface {
      network_id = yandex_vpc_network.k8s_vpc.id
      subnet_ids = [for key, value in yandex_vpc_subnet.k8s_subnets : value.id if value.name != "public"]
      nat        = var.instance_params["workers"].public_ip
      security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    }

    scheduling_policy {
      preemptible = var.instance_params["workers"].preemptible
    }

    metadata = {
      user-data          = data.template_file.web_cloudinit.rendered
      serial-port-enable = 1
    }
  }

  scale_policy {
    fixed_scale {
      size = var.instance_params["workers"].group_size
    }
  }

  allocation_policy {
    zones = [for key, value in yandex_vpc_subnet.k8s_subnets : value.zone if value.name != "public"]
  }

  deploy_policy {
    max_unavailable = var.instance_params["workers"].max_unavailable
    max_expansion   = var.instance_params["workers"].max_expansion
    max_creating    = var.instance_params["workers"].max_creating
    max_deleting    = var.instance_params["workers"].max_deleting
  }
}



resource "yandex_compute_instance_group" "control-plane" {
  depends_on         = [yandex_vpc_subnet.k8s_subnets]
  name               = var.masters_params.group_name
  folder_id          = var.folder_id
  service_account_id = data.yandex_iam_service_account.terraform.id
  instance_template {
    platform_id = var.masters_params.platform
    name        = "controller-{instance.index}"
    resources {
      memory        = var.masters_params.instance_memory
      cores         = var.masters_params.instance_cores
      core_fraction = var.masters_params.core_fraction
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.masters_image.id
        size     = var.masters_params.disk_size
      }
    }

    network_interface {
      network_id = yandex_vpc_network.k8s_vpc.id
      subnet_ids = [for key, value in yandex_vpc_subnet.k8s_subnets : value.id if value.name != "public"]
      nat        = var.masters_params.public_ip
      security_group_ids = [yandex_vpc_security_group.internal_bastion_sg.id]
    }

    scheduling_policy {
      preemptible = var.masters_params.preemptible
    }

    metadata = {
      user-data          = data.template_file.web_cloudinit.rendered
      serial-port-enable = 1
    }
  }

  scale_policy {
    fixed_scale {
      size = var.masters_params.group_size
    }
  }

  allocation_policy {
    zones = [for key, value in yandex_vpc_subnet.k8s_subnets : value.zone if value.name != "public"]
  }

  deploy_policy {
    max_unavailable = var.masters_params.max_unavailable
    max_expansion   = var.masters_params.max_expansion
    max_creating    = var.masters_params.max_creating
    max_deleting    = var.masters_params.max_deleting
  }
}

resource "yandex_compute_instance_group" "worker" {
  depends_on         = [yandex_vpc_subnet.k8s_subnets]
  name               = var.workers_params.group_name
  folder_id          = var.folder_id
  service_account_id = data.yandex_iam_service_account.terraform.id
  instance_template {
    platform_id = var.workers_params.platform
    name        = "worker-{instance.index}"
    resources {
      memory        = var.workers_params.instance_memory
      cores         = var.workers_params.instance_cores
      core_fraction = var.workers_params.core_fraction
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.workers_image.id
        size     = var.workers_params.disk_size
      }
    }

    network_interface {
      network_id = yandex_vpc_network.k8s_vpc.id
      subnet_ids = [for key, value in yandex_vpc_subnet.k8s_subnets : value.id if value.name != "public"]
      nat        = var.workers_params.public_ip
      security_group_ids = [yandex_vpc_security_group.internal_bastion_sg.id]
    }

    scheduling_policy {
      preemptible = var.workers_params.preemptible
    }

    metadata = {
      user-data          = data.template_file.web_cloudinit.rendered
      serial-port-enable = 1
    }
  }

  scale_policy {
    fixed_scale {
      size = var.workers_params.group_size
    }
  }

  allocation_policy {
    zones = [for key, value in yandex_vpc_subnet.k8s_subnets : value.zone if value.name != "public"]
  }

  deploy_policy {
    max_unavailable = var.workers_params.max_unavailable
    max_expansion   = var.workers_params.max_expansion
    max_creating    = var.workers_params.max_creating
    max_deleting    = var.workers_params.max_deleting
  }
}

resource "yandex_compute_instance" "bastion_vm" {
  name        = var.bastion_vm_params.name
  hostname    = var.bastion_vm_params.name
  platform_id = "standard-v2"
  zone        = yandex_vpc_subnet.bastion_subnet.zone

  resources {
    cores  = var.bastion_vm_params.instance_cores
    memory = var.bastion_vm_params.instance_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.bastion_image.id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.bastion_subnet.id
    nat        = var.bastion_vm_params.public_ip
    nat_ip_address = yandex_vpc_address.bastion_addr.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.secure_bastion_sg.id]
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s_subnets["k8s-a"].id
    nat = false
    ip_address = var.bastion_vm_params.internal_ip
    security_group_ids = [yandex_vpc_security_group.internal_bastion_sg.id]
  }


  scheduling_policy {
    preemptible = var.bastion_vm_params.preemptible
  }
  allow_stopping_for_update = true

  metadata = {
    user-data          = data.template_file.web_cloudinit.rendered
  }
}

resource "yandex_compute_instance" "nat_vm" {
  name        = var.nat_vm_params.name
  hostname    = var.nat_vm_params.name
  platform_id = "standard-v2"
  zone        = yandex_vpc_subnet.k8s_subnets[var.nat_vm_params.subnet].zone

  resources {
    cores  = var.nat_vm_params.instance_cores
    memory = var.nat_vm_params.instance_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat_image.id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.k8s_subnets[var.nat_vm_params.subnet].id
    nat        = var.nat_vm_params.public_ip
    ip_address = var.nat_vm_params.ip == null ? null : var.nat_vm_params.ip
    security_group_ids = [yandex_vpc_security_group.internal_bastion_sg.id]
  }

  scheduling_policy {
    preemptible = var.nat_vm_params.preemptible
  }
  allow_stopping_for_update = true

  metadata = {
    user-data          = data.template_file.web_cloudinit.rendered
  }
}
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name = "k8s-cluster"
  network_id = "${yandex_vpc_network.default.id}"

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = "${yandex_vpc_subnet.public-a.zone}"
        subnet_id = "${yandex_vpc_subnet.public-a.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.public-b.zone}"
        subnet_id = "${yandex_vpc_subnet.public-b.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.public-d.zone}"
        subnet_id = "${yandex_vpc_subnet.public-d.id}"
      }
    }

    security_group_ids = ["${yandex_vpc_security_group.k8s-main-sg.id}",
                          "${yandex_vpc_security_group.k8s-master-whitelist.id}"
    ]

    version   = "1.27"
    public_ip = true

    master_logging {
      enabled = true
      folder_id = "${var.yandex_folder_id}"
      kube_apiserver_enabled = true
      cluster_autoscaler_enabled = true
      events_enabled = true
      audit_enabled = true
    }
  }
  service_account_id      = "${var.sa_k8s_id}"
  node_service_account_id = "${var.sa_k8s_id}"
}

# Create worker-nodes-a
resource "yandex_kubernetes_node_group" "worker-nodes-a" {
  cluster_id = "${yandex_kubernetes_cluster.k8s-cluster.id}"
  name       = "worker-nodes-a"
  version    = "1.26"
  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.public-a.id}"]
      security_group_ids = [
        "${yandex_vpc_security_group.k8s-main-sg.id}",
        "${yandex_vpc_security_group.k8s-nodes-ssh-access.id}",
        "${yandex_vpc_security_group.k8s-public-services.id}"
      ]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
  }
  }

  allocation_policy {
    location {
      zone = "${yandex_vpc_subnet.public-a.zone}"
    }
  }
}


# Create worker-nodes-b
resource "yandex_kubernetes_node_group" "worker-nodes-b" {
  cluster_id = "${yandex_kubernetes_cluster.k8s-cluster.id}"
  name       = "worker-nodes-b"
  version    = "1.26"
  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.public-b.id}"]
      security_group_ids = [
        "${yandex_vpc_security_group.k8s-main-sg.id}",
        "${yandex_vpc_security_group.k8s-nodes-ssh-access.id}",
        "${yandex_vpc_security_group.k8s-public-services.id}"
      ]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
  }
  }

  allocation_policy {
    location {
      zone = "${yandex_vpc_subnet.public-b.zone}"
    }
  }
}

# Create worker-nodes-d
resource "yandex_kubernetes_node_group" "worker-nodes-d" {
  cluster_id = "${yandex_kubernetes_cluster.k8s-cluster.id}"
  name       = "worker-nodes-d"
  version    = "1.26"
  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.public-d.id}"]
      security_group_ids = [
        "${yandex_vpc_security_group.k8s-main-sg.id}",
        "${yandex_vpc_security_group.k8s-nodes-ssh-access.id}",
        "${yandex_vpc_security_group.k8s-public-services.id}"
      ]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
  }
  }

  allocation_policy {
    location {
      zone = "${yandex_vpc_subnet.public-d.zone}"
    }
  }
}
default_zone = "ru-central1-a"
admin        = "nedorezov"
vm_packages  = ["vim", "net-tools"]

vpc_params = {
  name = "k8s-vpc"
  subnets = {
    public = { zone = "ru-central1-b", cidr = "192.168.0.0/24" },
    k8s-a  = { zone = "ru-central1-a", cidr = "10.0.1.0/24", route_nat = true },
    k8s-b  = { zone = "ru-central1-b", cidr = "10.0.2.0/24", route_nat = true },
    k8s-d  = { zone = "ru-central1-d", cidr = "10.0.3.0/24", route_nat = true },
  }
}

instance_params = {
  masters = {
    group_name      = "k8s-control-plane"
    group_size      = 3
    vm_name         = "controller"
    platform        = "standard-v2"
    image_family    = "ubuntu-2404-lts-oslogin"
    core_fraction   = 20
    instance_cores  = 2
    instance_memory = 4
    disk_size       = 30
    public_ip       = false
    max_unavailable = 3
    max_expansion   = 3
    max_creating    = 3
    max_deleting    = 3
    preemptible     = false
  }
  workers = {
    group_name      = "k8s-workers"
    group_size      = 3
    vm_name         = "worker"
    platform        = "standard-v2"
    image_family    = "ubuntu-2404-lts-oslogin"
    core_fraction   = 20
    instance_cores  = 2
    instance_memory = 4
    disk_size       = 30
    public_ip       = false
    max_unavailable = 3
    max_expansion   = 3
    max_creating    = 3
    max_deleting    = 3
    preemptible     = true
  }
  bastion = {
    vm_name         = "bastion"
    platform        = "standard-v2"
    image_family    = "nat-instance-ubuntu"
    subnet          = "public"
    core_fraction   = 100
    instance_cores  = 4
    instance_memory = 4
    disk_size       = 20
    public_ip       = true
    preemptible     = false
  }
}
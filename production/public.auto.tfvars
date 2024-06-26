default_zone = "ru-central1-a"
admin        = "nedorezov"
vm_packages  = ["vim"]

k8s_vpc_params = {
  name = "k8s-vpc"
  subnets = {
    public = { zone = "ru-central1-b", cidr = "192.168.0.0/24" },
    k8s-a  = { zone = "ru-central1-a", cidr = "10.0.1.0/24", route_nat = true },
    k8s-b  = { zone = "ru-central1-b", cidr = "10.0.2.0/24", route_nat = true },
    k8s-c  = { zone = "ru-central1-d", cidr = "10.0.3.0/24", route_nat = true },
  }
}

instance_params = {
  masters = {
    group_name      = "control-plane"
    group_size      = 3
    public_ip       = false
    preemptible     = false
    max_unavailable = 3
    max_expansion   = 3
    max_creating    = 3
    max_deleting    = 3
  }
  workers = {
    group_name      = "worker"
    group_size      = 3
    public_ip       = false
    preemptible     = false
    max_unavailable = 3
    max_expansion   = 3
    max_creating    = 3
    max_deleting    = 3
  }
}

masters_params = {
  group_name      = "control-plane"
  platform        = "standard-v2"
  image_family    = "ubuntu-2004-lts"
  core_fraction   = 20
  instance_cores  = 2
  instance_memory = 4
  disk_size       = 30
  group_size      = 3
  public_ip       = false
  max_unavailable = 3
  max_expansion   = 3
  max_creating    = 3
  max_deleting    = 3
  preemptible     = false
}

workers_params = {
  group_name      = "worker"
  platform        = "standard-v2"
  image_family    = "ubuntu-2004-lts"
  core_fraction   = 20
  instance_cores  = 2
  instance_memory = 4
  disk_size       = 30
  group_size      = 3
  public_ip       = false
  max_unavailable = 3
  max_expansion   = 3
  max_creating    = 3
  max_deleting    = 3
  preemptible     = true
}

bastion_vm_params = {
  name            = "bastion"
  image_family    = "ubuntu-2004-lts"
  subnet          = "bastion"
  public_ip       = true
  instance_cores  = 2
  instance_memory = 2
  boot_disk_size  = 30
  preemptible     = false
}
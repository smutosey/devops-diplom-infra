variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "admin" {
  description = "name of predefined user on VM"
  type        = string
}

variable "ssh_public_key" {
  type        = string
  description = "Location of SSH public key."
}

variable "vm_packages" {
  type        = list(string)
  description = "Packages to install on vm creates"
}

variable "k8s_vpc_params" {
  description = "Production VPC environment variables"
  type = object({
    name = string
    subnets = map(object({
      zone      = string
      cidr      = string
      route_nat = optional(bool)
    }))
  })
}

variable "bastion_vpc_params" {
  description = "Production VPC environment variables"
  type = object({
    name   = string
    subnet = string
    zone   = string
    cidr   = string
  })
}

variable "masters_params" {
  type = object({
    group_name      = string
    platform        = string
    image_family    = string
    core_fraction   = number
    instance_cores  = number
    instance_memory = number
    disk_size       = number
    group_size      = number
    public_ip       = bool
    max_unavailable = number
    max_expansion   = number
    max_creating    = number
    max_deleting    = number
    preemptible     = bool
  })
  description = "k8s control plane VM group params"
}

variable "workers_params" {
  type = object({
    group_name      = string
    platform        = string
    image_family    = string
    core_fraction   = number
    instance_cores  = number
    instance_memory = number
    disk_size       = number
    group_size      = number
    public_ip       = bool
    max_unavailable = number
    max_expansion   = number
    max_creating    = number
    max_deleting    = number
    preemptible     = bool
  })
  description = "k8s workers VM group params"
}

variable "nat_vm_params" {
  type = object({
    name            = string
    image_family    = string
    subnet          = string
    public_ip       = bool
    ip              = optional(string)
    instance_cores  = number
    instance_memory = number
    boot_disk_size  = number
    preemptible     = bool
  })
  description = "NAT VM params (key = instance name)"
}

variable "bastion_vm_params" {
  type = object({
    name            = string
    image_family    = string
    subnet          = string
    public_ip       = bool
    internal_ip     = string
    instance_cores  = number
    instance_memory = number
    boot_disk_size  = number
    preemptible     = bool
  })
  description = "Bastion VM params (key = instance name)"
}
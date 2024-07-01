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

variable "ssh_private_key" {
  type        = string
  description = "Location of SSH private key."
}

variable "vm_packages" {
  type        = list(string)
  description = "Packages to install on vm creates"
}

variable "vpc_params" {
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

variable "instance_params" {
  description = "instance params"
  type = map(object({
    group_name      = optional(string)
    group_size      = optional(number)
    subnet          = optional(string)
    vm_name         = string
    platform        = string
    image_family    = string
    core_fraction   = number
    instance_cores  = number
    instance_memory = number
    disk_size       = number
    public_ip       = bool
    internal_ip     = optional(string)
    max_unavailable = optional(number)
    max_expansion   = optional(number)
    max_creating    = optional(number)
    max_deleting    = optional(number)
    preemptible     = bool
  }))
}

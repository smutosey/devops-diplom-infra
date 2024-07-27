# Переменные для манифестов terraform
# Значения в основном объявлены в public.auto.tfvars, остальные берем из секретов
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

variable "service_account" {
  description = "name of service account in YC folder for creating infra"
  type        = string
}

variable "ssh_public_key_b64" {
  type        = string
  description = "SSH public key base64 encoded"
}

variable "ssh_private_key_b64" {
  type        = string
  description = "SSH private key base64 encoded"
}

variable "sa_key_b64" {
  type        = string
  description = "SA json key base64 encoded"
}

variable "github_token" {
  type        = string
  description = "Atlantis GitHub token name"
  default     = ""
}

variable "github_secret" {
  type        = string
  description = "Atlantis GitHub token secret"
  default     = ""
}

variable "vm_packages" {
  type        = list(string)
  description = "Packages to install on vm creates"
}

variable "access_key" {
  type    = string
  default = ""
}
variable "secret_key" {
  type    = string
  default = ""
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

variable "dns_params" {
  description = "DNS variables"
  type = object({
    domain         = string
    subdomains     = list(string)
    certificate_id = string
    dns_zone_id    = string
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

variable "cr_params" {
  description = "container registry params"
  type = object({
    registry_name   = string
    repository_name = string
  })
}

variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "terraform_sa_access_key_id" {
  type        = string
  description = "https://yandex.cloud/en/docs/iam/concepts/authorization/access-key"
}

variable "terraform_sa_secret_key" {
  type        = string
  description = "https://yandex.cloud/en/docs/iam/concepts/authorization/access-key"
}

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


variable "vpc_params" {
  type = object({
    name = string
    subnets = list(object({
      zone = string
      cidr = string
    }))
  })
  description = "Network params for vms k8s cluster"
  default = {
    name = "k8s-network"
    subnets = [
      { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
      { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
      { zone = "ru-central1-d", cidr = "10.0.3.0/24" },
    ]
  }
}
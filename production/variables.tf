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

variable "backend_access_key" {
  type        = string
}

variable "backend_secret_key" {
  type        = string
}

variable "backend_bucket_name" {
  type        = string
}

variable "backend_tfstatedb_endpoint" {
  type        = string
}

variable "backend_tfstatedb_table" {
  type        = string
}


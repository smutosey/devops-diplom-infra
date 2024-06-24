variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
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

variable "sa_params" {
  type = object({
    name                = string
    roles               = list(string)
    backend_config_path = string
    backend_key_path    = string
  })
  description = "Service account params for production"
}

variable "backend_params" {
  type = object({
    bucket_name          = string
    kms_key_name         = string
    statelock_db_name    = string
    statelock_table_name = string
  })
  description = "Service account params for production"
}
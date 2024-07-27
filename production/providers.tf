# инициализация провайдера yandex и terraform remote state
terraform {
  required_version = ">=0.13"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  backend "s3" {
    endpoints = {
      s3       = "https://storage.yandexcloud.net"
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gvv09q0t0tnutrh88e/etnb8gv6pcuq08gf6ugp"
    }
    bucket = "nedorezov-tf-state-bucket"
    region = "ru-central1"
    key    = "production.tfstate"

    dynamodb_table = "state-lock-table"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}

provider "yandex" {
  service_account_key_file = base64decode(var.sa_key_b64) # file("terraform_sa_key.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
}
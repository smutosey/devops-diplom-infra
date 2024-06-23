data "yandex_ydb_database_serverless" "tflock" {
  database_id = "some_ydb_serverless_database_id"
}


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
      dynamodb =
    }
    bucket = "nedorezov-tf-state-bucket"
    region = "ru-central1"
    key    = "production.tfstate"

    dynamodb_table = "state-lock-table"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = file("~/terraform_sa_key.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
}
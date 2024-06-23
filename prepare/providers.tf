terraform {
  required_version = ">=0.13"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

provider "aws" {
  region = "ru-central1"
  endpoints {
    dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gvv09q0t0tnutrh88e/etnb8gv6pcuq08gf6ugp"
  }
  profile = "backend"
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_region_validation = true
  skip_requesting_account_id = true
}
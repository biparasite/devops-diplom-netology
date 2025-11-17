terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
# https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-lock
  backend "s3" {
    endpoints = {
      s3       = "https://storage.yandexcloud.net"
      dynamodb = var.dynamodb
      #dynamodb = хранится в backend-config.tfvars ..
    }
    bucket            = "iam-bucket-asv-sula"
    region            = "ru-central1"
    key               = "s3backend/s3.tfstate"
    dynamodb_table = "lock"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}


provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = file("~/Downloads/authorized_key-9.json")
}

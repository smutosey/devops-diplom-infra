# Загрузка состояний Terraform в Yandex Object Storage
resource "yandex_kms_symmetric_key" "encryption_key" {
  depends_on = [
    yandex_resourcemanager_folder_iam_member.terraform_sa_encrypter,
    yandex_resourcemanager_folder_iam_member.terraform_sa_decrypter,
  ]
  name              = "storage-encryption-key"
  description       = "Key for encrypting bucket objects"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_storage_bucket" "tf_state_bucket" {
  depends_on = [yandex_resourcemanager_folder_iam_member.terraform_sa_storage]

  bucket     = "nedorezov-tf-state-bucket"
  access_key = yandex_iam_service_account_static_access_key.terraform_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_key.secret_key

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.encryption_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Блокировка состояний Terraform с помощью Yandex Managed Service for YDB
resource "yandex_ydb_database_serverless" "db_tf_state_lock" {
  depends_on          = [yandex_resourcemanager_folder_iam_member.terraform_sa_ydb]
  name                = "state-lock-db"
  deletion_protection = true

  serverless_database {}
}

resource "yandex_ydb_table" "table_tf_state_lock" {
  depends_on = [yandex_ydb_database_serverless.db_tf_state_lock]

  path              = "state-lock-table"
  connection_string = yandex_ydb_database_serverless.db_tf_state_lock.ydb_full_endpoint

  lifecycle {
    ignore_changes = [column]
  }

  primary_key = ["LockID"]

  column {
    name     = "LockID"
    not_null = false
    type     = "String"
  }

  partitioning_settings {
    auto_partitioning_by_load              = false
    auto_partitioning_by_size_enabled      = true
    auto_partitioning_max_partitions_count = 0
    auto_partitioning_min_partitions_count = 1
    auto_partitioning_partition_size_mb    = 2048
    uniform_partitions                     = 0
  }
}

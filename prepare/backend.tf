# Загрузка состояний Terraform в Yandex Object Storage
resource "yandex_kms_symmetric_key" "encryption_key" {
  depends_on = [yandex_resourcemanager_folder_iam_member.terraform_sa_roles]
  name              = var.backend_params.kms_key_name
  description       = "Key for encrypting bucket objects"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_storage_bucket" "tf_state_bucket" {
  depends_on = [yandex_resourcemanager_folder_iam_member.terraform_sa_roles]

  bucket     = var.backend_params.bucket_name
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
  depends_on          = [yandex_resourcemanager_folder_iam_member.terraform_sa_roles]
  name                = var.backend_params.statelock_db_name
  deletion_protection = true

  serverless_database {}
}

resource "aws_dynamodb_table" "table_tf_state_lock" {
  name         = var.backend_params.statelock_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}



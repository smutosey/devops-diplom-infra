# Создание статических ключей для подключения
resource "local_file" "backend_config" {
  depends_on = [yandex_iam_service_account_static_access_key.terraform_key]
  content    = <<EOT
access_key = "${yandex_iam_service_account_static_access_key.terraform_key.access_key}"
secret_key = "${yandex_iam_service_account_static_access_key.terraform_key.secret_key}"
EOT
  filename   = var.sa_params.backend_config_path
}

# Создание авторизованного ключа для подключения
resource "null_resource" "terraform_sa_iam" {
  depends_on = [yandex_resourcemanager_folder_iam_member.terraform_sa_roles]
  provisioner "local-exec" {
    command = "yc iam key create --folder-id ${var.folder_id} --service-account-name ${yandex_iam_service_account.terraform_sa.name} --output ${var.sa_params.backend_key_path}"
  }
}

output "dynamodb_endpoint" {
  value = yandex_ydb_database_serverless.db_tf_state_lock.document_api_endpoint
}
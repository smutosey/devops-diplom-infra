# Сервисный аккаунт Terraform
resource "yandex_iam_service_account" "terraform_sa" {
  name = "terraform-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_compute" {
  depends_on = [yandex_iam_service_account.terraform_sa]
  folder_id  = var.folder_id
  role       = "compute.editor"
  member     = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_lb" {
  depends_on = [yandex_iam_service_account.terraform_sa]
  folder_id  = var.folder_id
  role       = "load-balancer.admin"
  member     = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_storage" {
  depends_on = [yandex_iam_service_account.terraform_sa]
  folder_id  = var.folder_id
  role       = "storage.editor"
  member     = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_encrypter" {
  depends_on = [yandex_iam_service_account.terraform_sa]
  folder_id  = var.folder_id
  role       = "kms.keys.encrypter"
  member     = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_decrypter" {
  depends_on = [yandex_iam_service_account.terraform_sa]
  folder_id  = var.folder_id
  role       = "kms.keys.decrypter"
  member     = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_ydb" {
  depends_on = [yandex_iam_service_account.terraform_sa]
  folder_id  = var.folder_id
  role       = "ydb.editor"
  member     = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "terraform_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
}

# Создание статических ключей для подключения
resource "local_file" "backend_config" {
  depends_on = [yandex_iam_service_account_static_access_key.terraform_key]
  content    = <<EOT
backend_access_key = "${yandex_iam_service_account_static_access_key.terraform_key.access_key}"
backend_secret_key = "${yandex_iam_service_account_static_access_key.terraform_key.secret_key}"
backend_bucket_name  = "${yandex_storage_bucket.tf_state_bucket.bucket}"
backend_tfstatedb_endpoint = "${yandex_ydb_database_serverless.db_tf_state_lock.document_api_endpoint}"
backend_tfstatedb_table = "${yandex_ydb_table.table_tf_state_lock.path}"
EOT
  filename   = "../production/backend-config.tfvars"
}

# Создание авторизованного ключа для подключения
resource "null_resource" "terraform_sa_iam" {
  depends_on = [yandex_resourcemanager_folder_iam_member.terraform_sa_compute]
  provisioner "local-exec" {
    command = "yc iam key create --folder-id ${var.folder_id} --service-account-name ${yandex_iam_service_account.terraform_sa.name} --output ../production/terraform_sa_key.json"
  }
}
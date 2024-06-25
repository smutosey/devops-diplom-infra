# Сервисный аккаунт Terraform
resource "yandex_iam_service_account" "terraform_sa" {
  name = var.sa_params.name
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_roles" {
  depends_on = [yandex_iam_service_account.terraform_sa]
  for_each   = toset(var.sa_params.roles)
  folder_id  = var.folder_id
  role       = each.value
  member     = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "terraform_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
}

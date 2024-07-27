# Создание Container Registry
resource "yandex_container_registry" "nedorezov-netology-apps" {
  folder_id = var.folder_id
  name      = var.cr_params.registry_name
}

# Создание репозитория 
resource "yandex_container_repository" "netology-demo" {
  name = "${yandex_container_registry.nedorezov-netology-apps.id}/${var.cr_params.repository_name}"
}

# Права на pull и push образов
resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.nedorezov-netology-apps.id
  role        = "container-registry.images.puller"

  members = [
    "system:allUsers",
  ]
}
resource "yandex_container_registry_iam_binding" "pusher" {
  registry_id = yandex_container_registry.nedorezov-netology-apps.id
  role        = "container-registry.images.pusher"

  members = [
    "system:allUsers",
  ]
}
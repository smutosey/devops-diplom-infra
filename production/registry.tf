resource yandex_container_registry "nedorezov-netology-apps" {
  folder_id = var.folder_id
  name      = "nedorezov-netology-apps"
}

resource "yandex_container_repository" "smutosey-demo" {
  name = "${yandex_container_registry.nedorezov-netology-apps.id}/smutosey-demo"
}

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
# Infrastructure for diploma work in Netology

Репозиторий с конфигурацией Terraform для создания инфраструктуры в Yandex.Cloud по задачам дипломного практикума курса "DevOps-инженер" Нетологии.

### [Цели](https://github.com/netology-code/devops-diplom-yandexcloud)
- Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
- Запустить и сконфигурировать Kubernetes кластер.
- Установить и настроить систему мониторинга.
---

### Структура репозитория
- [.github/](.github) - Инструкции GitHub Actions для создания инфраструктуры
  1. Terraform plan + apply
  2. Kubespray run playbook
  3. Helm upgrade
- [prepare/](prepare) - Конфигурация Terraform для предварительной подготовки облака
  1. S3-backend Terraform для production
  2. Сервисный аккаунт с необходимыми правами для создания production
- [production/](production) - Конфигурация Terraform для создания инфраструктуры по [ТЗ](https://github.com/netology-code/devops-diplom-yandexcloud)
  - [/templates/](production/templates) - шаблоны для terraform
  - [/ansible/](production/ansible) - параметры для создания кластера k8s через Kubespray
  - [/helm/](production/helm) - параметры для установки Kube Prometheus Stack и Atlantis через Helm
  - [providers.tf](production/providers.tf) - инициализация провайдера Yandex Cloud и Terraform remote backend (S3)
  - [variables.tf](production/variables.tf) - объявление переменных для конфигурации Terraform
  - [public.auto.tfvars](production/public.auto.tfvars) - значения переменных (кроме секретов)
  - [compute.tf](production/compute.tf) - compute cloud (бастион и ноды k8s)
  - [data.tf](production/data.tf) - данные ресурсов в YC
  - [network.tf](production/network.tf) - создание сети и подсетей
  - [network-security.tf](production/network-security.tf) - группы безопасности и правила ingress/egress
  - [load-balancing.tf](production/load-balancing.tf) - Network load balancer для control-plane и Application load balancer для приложений в кластере
  - [registry.tf](production/registry.tf) - Container Registry для собранных образов приложений
  - [ansible.tf](production/ansible.tf) - создание inventory для Kubespray на основе созданных ресурсов в YC
  
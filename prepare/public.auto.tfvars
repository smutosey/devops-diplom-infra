default_zone = "ru-central1-a"
sa_params = {
  name = "terraform-sa"
  roles = [
    "compute.editor",
    "load-balancer.admin",
    "storage.editor",
    "kms.keys.encrypter",
    "kms.keys.decrypter",
    "ydb.editor",
    "vpc.admin",
    "iam.serviceAccounts.user",
  ]
  backend_config_path = "../production/backend-config.tfvars"
  backend_key_path    = "../production/terraform_sa_key.json"
}
backend_params = {
  bucket_name          = "nedorezov-tf-state-bucket"
  kms_key_name         = "storage-encryption-key"
  statelock_db_name    = "state-lock-db"
  statelock_table_name = "state-lock-table"
}
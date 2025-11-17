default_zone = "ru-central1-a"
sa_params = {
  name = "terraform-sa"
  roles = [
    "compute.editor",
    "load-balancer.admin",
    "storage.admin",
    "kms.keys.encrypter",
    "kms.keys.decrypter",
    "ydb.editor",
    "vpc.admin",
    "vpc.publicAdmin",
    "iam.serviceAccounts.user",
    "alb.editor",
    "certificate-manager.editor",
    "certificate-manager.certificates.downloader",
    "container-registry.admin",
    "dns.editor",
  ]
  backend_config_path = "../terraform-backend/backend-config.tfvars"
  backend_key_path    = "~/Download/terraform_sa_key.json"
}
backend_params = {
  bucket_name          = "iam-bucket-asv-sula"
  kms_key_name         = "storage-encryption-key"
  statelock_db_name    = "terraform-state-lock"
  statelock_table_name = "lock"
}

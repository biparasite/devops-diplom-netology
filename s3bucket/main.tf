# Загрузка состояний Terraform в Yandex Object Storage
resource "yandex_kms_symmetric_key" "s3_key" {
  depends_on = [yandex_resourcemanager_folder_iam_member.terraform_sa_roles]
  name              = var.backend_params.kms_key_name
  folder_id         = var.folder_id
  description       = "Key for encrypting bucket objects"
  default_algorithm = "AES_256"
  rotation_period   = "24h"
  lifecycle {
    prevent_destroy = false
  }
}

resource "yandex_storage_bucket" "tf_state_bucket" {
  depends_on = [yandex_kms_symmetric_key.s3_key]
  max_size              = 10485760
  default_storage_class = "standard"
  force_destroy = true
  bucket     = var.backend_params.bucket_name
  access_key = yandex_iam_service_account_static_access_key.terraform_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_key.secret_key

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.s3_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }
    versioning {
    enabled = true
  }
}

variable "cloud_id" {
    type=string
    default="b1gd2j85a1qkvque4sv7"
}
variable "folder_id" {
    type=string
    default="b1g58l0sc9sfdif3gs79"
}
variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "ru-central1-a"
}

variable "sa_params" {
  type = object({
    name                = string
    roles               = list(string)
    backend_config_path = string
    backend_key_path    = string
  })
  description = "Service account params for production"
}

variable "backend_params" {
  type = object({
    bucket_name          = string
    kms_key_name         = string
    statelock_db_name    = string
    statelock_table_name = string
  })
  description = "Service account params for production"
}

variable "dynamodb" {
    type=string
}
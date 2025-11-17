variable "cloud_id" {
    type=string
}
variable "folder_id" {
    type=string
}

variable "svc_account_id" {
  type        = string
  }

variable "dynamodb" {
  type        = string
  }
  
variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "ru-central1-a"
}

variable "vm_name" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "name system"
}

data "yandex_compute_image" "debian_12" {
  family = "debian-12" #
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "spcontrolnode" {
  type = number
  default = 1
}

variable "spworknode_group" {
  type = number
  default = 3
}

# ControlNode
variable "vm_controlnode_instance_platform_id" {
  type        = string
  default     = "standard-v2"
  description = "Platform ID"
}

variable "vm_controlnode_resources" {
  type = map(any)
  default = {
    "cores"         = 8
    "memory"        = 8
    "core_fraction" = 100
    "size"          = 20
    "type"          = "network-ssd"
  }
  description = "ControlNode"
}

variable "vm_controlnode_instance_scheduling_policy" {
  type        = bool
  default     = true
  description = "Scheduling policy"
}

variable "vm_controlnode_instance_network_interface_nat" {
  type        = bool
  default     = true
  description = "Interface NAT"
}

# WorkerNode
variable "vm_worknode_instance_platform_id" {
  type        = string
  default     = "standard-v2"
  description = "Platform ID"
}

variable "vm_worknode_resources" {
  type = map(any)
  default = {
    "cores"         = 4
    "memory"        = 4
    "core_fraction" = 50
    "size"          = 20
    "type"          = "network-hdd"
  }
  description = "workernode"
}


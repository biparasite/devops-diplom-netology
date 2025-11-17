resource "yandex_compute_instance_group" "controlnode" {
  name                = "controlnode"
  folder_id           = var.folder_id
  service_account_id  = var.svc_account_id
  deletion_protection = false
  instance_template {
    platform_id = var.vm_worknode_instance_platform_id
    name        = "controlnode-{instance.index}"
    hostname    = "controlnode-{instance.index}"
  
    resources {
      cores               = var.vm_controlnode_resources.cores
      memory              = var.vm_controlnode_resources.memory
      core_fraction       = var.vm_controlnode_resources.core_fraction
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.debian_12.image_id
        type     = var.vm_controlnode_resources.type
        size     = var.vm_controlnode_resources.size
      }
    }

    scheduling_policy {
    preemptible = true
  }
    network_interface {
        network_id = yandex_vpc_network.develop.id
        subnet_ids = [yandex_vpc_subnet.subnet-a.id, yandex_vpc_subnet.subnet-b.id, yandex_vpc_subnet.subnet-d.id]
        nat        = true
        ipv6       = false
        security_group_ids = [
        yandex_vpc_security_group.k8s-acl.id
      ]
      }

    metadata = {
      user-data          = file("./cloud-init.yml")
      serial-port-enable = 1
      }
  }
  scale_policy {
    fixed_scale {
      size = var.spcontrolnode
    }
  }
  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
}
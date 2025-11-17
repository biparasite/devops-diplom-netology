resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnet-a" {
  name            = "subnet-a"
  zone            = "ru-central1-a"
  network_id      = yandex_vpc_network.develop.id
  v4_cidr_blocks  = [var.subnet_cidr_blocks[0]]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name            = "subnet-b"
  zone            = "ru-central1-b"
  network_id      = yandex_vpc_network.develop.id
  v4_cidr_blocks  = [var.subnet_cidr_blocks[1]]
}

resource "yandex_vpc_subnet" "subnet-d" {
  name            = "subnet-d"
  zone            = "ru-central1-d"
  network_id      = yandex_vpc_network.develop.id
  v4_cidr_blocks  = [var.subnet_cidr_blocks[2]]
}

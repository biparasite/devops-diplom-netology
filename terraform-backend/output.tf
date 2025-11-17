resource "local_file" "ansible_inventory_file" {
  content = templatefile("${path.module}/ansible_template/template.tpl", {
    Control_node = yandex_compute_instance_group.controlnode.instances.*.network_interface.0.nat_ip_address
    Worker_node = yandex_compute_instance_group.worknode_group.instances.*.network_interface.0.nat_ip_address
  })
  filename = "${path.module}/ansible/inventory.yaml"
}

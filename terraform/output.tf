output "bastion_public_ip" {
  value = "${azurerm_public_ip.bastion.ip_address}"
}

output "console_public_ip" {
  value = "${azurerm_public_ip.master.ip_address}"
}

output "service_public_ip" {
  value = "${azurerm_public_ip.infra.ip_address}"
}

output "node_count" {
  value = "${var.openshift_node_count}"
}

output "admin_user" {
  value = "${var.openshift_vm_admin_user}"
}

output "master_domain" {
  value = "${var.openshift_master_domain}"
}

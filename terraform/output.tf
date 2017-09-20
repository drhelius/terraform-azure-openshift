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
  value = "${var.node_count}"
}

output "admin_user" {
  value = "${var.admin_user}"
}

output "master_domain" {
  value = "${var.master_domain}"
}

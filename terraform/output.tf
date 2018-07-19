output "bastion_public_ip" {
  value = "${azurerm_public_ip.bastion.ip_address}"
}

output "console_public_ip" {
  value = "${azurerm_public_ip.master-public.ip_address}"
}

output "router_public_ip" {
  value = "${azurerm_public_ip.infra.ip_address}"
}

output "node_count" {
  value = "${var.openshift_node_count}"
}

output "master_count" {
  value = "${var.openshift_master_count}"
}

output "infra_count" {
  value = "${var.openshift_infra_count}"
}

output "admin_user" {
  value = "${var.openshift_vm_admin_user}"
}

output "master_domain" {
  value = "${var.openshift_master_domain}"
}

output "router_domain" {
  value = "${var.openshift_router_domain}"
}

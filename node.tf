resource "azurerm_network_interface" "node" {
  count               = "${var.node_count}"
  name                = "openshift-node-nic-${count.index}"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"

  ip_configuration {
    name                          = "default"
    subnet_id                     = "${azurerm_subnet.node.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_storage_container" "node" {
  count                 = "${var.node_count}"
  name                  = "node-${count.index}"
  resource_group_name   = "${azurerm_resource_group.openshift.name}"
  storage_account_name  = "${azurerm_storage_account.openshift.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "node" {
  count                 = "${var.node_count}"
  name                  = "openshift-node-vm-${count.index}"
  location              = "${var.azure_location}"
  resource_group_name   = "${azurerm_resource_group.openshift.name}"
  network_interface_ids = ["${element(azurerm_network_interface.node.*.id, count.index)}"]
  vm_size               = "${var.node_vm_size}"

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_image_sku}"
    version   = "${var.os_image_version}"
  }

  storage_os_disk {
    name              = "openshift-node-vm-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "openshift-node-vm-data-disk-${count.index}"
    create_option     = "Empty"
    managed_disk_type = "Standard_LRS"
    lun               = 0
    disk_size_gb      = 20
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "node${count.index}"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${var.admin_sshcert}"
    }
  }
}

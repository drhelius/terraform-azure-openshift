resource "azurerm_public_ip" "bastion" {
  name                         = "openshift-bastion-public-ip"
  location                     = "${var.azure_location}"
  resource_group_name          = "${azurerm_resource_group.openshift.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "bastion" {
  name                      = "openshift-bastion-nic"
  location                  = "${var.azure_location}"
  resource_group_name       = "${azurerm_resource_group.openshift.name}"
  network_security_group_id = "${azurerm_network_security_group.bastion.id}"

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = "${azurerm_public_ip.bastion.id}"
    subnet_id                     = "${azurerm_subnet.master.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_security_group" "bastion" {
  name                = "openshift-bastion-security-group"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
}

resource "azurerm_network_security_rule" "bastion-ssh" {
  name                        = "bastion-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = 22
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.openshift.name}"
  network_security_group_name = "${azurerm_network_security_group.bastion.name}"
}

resource "azurerm_virtual_machine" "bastion" {
  name                  = "openshift-bastion-vm"
  location              = "${var.azure_location}"
  resource_group_name   = "${azurerm_resource_group.openshift.name}"
  network_interface_ids = ["${azurerm_network_interface.bastion.id}"]
  vm_size               = "${var.bastion_vm_size}"

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_image_sku}"
    version   = "${var.os_image_version}"
  }

  storage_os_disk {
    name              = "openshift-bastion-vm-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "bastion"
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

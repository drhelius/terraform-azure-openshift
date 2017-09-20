resource "azurerm_public_ip" "master" {
  name                         = "openshift-master-public-ip"
  location                     = "${var.azure_location}"
  resource_group_name          = "${azurerm_resource_group.openshift.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_availability_set" "master" {
  name                = "openshift-master-availability-set"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
  managed             = true
}

resource "azurerm_lb" "master" {
  name                = "openshift-master-load-balancer"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"

  frontend_ip_configuration {
    name                          = "default"
    public_ip_address_id          = "${azurerm_public_ip.master.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "master" {
  name                = "openshift-master-address-pool"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
  loadbalancer_id     = "${azurerm_lb.master.id}"
}

resource "azurerm_lb_rule" "master-8443-8443" {
  name                    = "master-lb-rule-8443-8443"
  resource_group_name     = "${azurerm_resource_group.openshift.name}"
  loadbalancer_id         = "${azurerm_lb.master.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.master.id}"
  protocol                       = "tcp"
  frontend_port                  = 8443
  backend_port                   = 8443
  frontend_ip_configuration_name = "default"
}

resource "azurerm_network_security_group" "master" {
  name                = "openshift-master-security-group"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
}

resource "azurerm_network_security_rule" "master-8443" {
  name                        = "master-8443"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 8443
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.openshift.name}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_interface" "master" {
  count                     = 3
  name                      = "openshift-master-nic-${count.index}"
  location                  = "${var.azure_location}"
  resource_group_name       = "${azurerm_resource_group.openshift.name}"
  network_security_group_id = "${azurerm_network_security_group.master.id}"

  ip_configuration {
    name                                    = "default"
    subnet_id                               = "${azurerm_subnet.master.id}"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.master.id}"]
  }
}

resource "azurerm_virtual_machine" "master" {
  count                 = 3
  name                  = "openshift-master-vm-${count.index}"
  location              = "${var.azure_location}"
  resource_group_name   = "${azurerm_resource_group.openshift.name}"
  network_interface_ids = ["${element(azurerm_network_interface.master.*.id, count.index)}"]
  vm_size               = "${var.master_vm_size}"
  availability_set_id   = "${azurerm_availability_set.master.id}"

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_image_sku}"
    version   = "${var.os_image_version}"
  }

  storage_os_disk {
    name              = "openshift-master-vm-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "openshift-master-vm-data-disk-${count.index}"
    create_option     = "Empty"
    managed_disk_type = "Standard_LRS"
    lun               = 0
    disk_size_gb      = 20
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "master${count.index}"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${file("${path.module}/../certs/openshift.pub")}"
    }
  }
}

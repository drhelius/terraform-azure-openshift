resource "azurerm_public_ip" "infra" {
  name                         = "openshift-infrastructure-public-ip"
  location                     = "${var.azure_location}"
  resource_group_name          = "${azurerm_resource_group.openshift.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_availability_set" "infra" {
  name                = "openshift-infrastructure-availability-set"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
  managed             = true
}

resource "azurerm_lb" "infra" {
  name                = "openshift-infrastructure-load-balancer"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"

  frontend_ip_configuration {
    name                          = "default"
    public_ip_address_id          = "${azurerm_public_ip.infra.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "infra" {
  name                = "openshift-infrastructure-address-pool"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
  loadbalancer_id     = "${azurerm_lb.infra.id}"
}

resource "azurerm_lb_rule" "infra-80-80" {
  name                    = "infra-lb-rule-80-80"
  resource_group_name     = "${azurerm_resource_group.openshift.name}"
  loadbalancer_id         = "${azurerm_lb.infra.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.infra.id}"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_rule" "infra-443-443" {
  name                    = "infra-lb-rule-443-443"
  resource_group_name     = "${azurerm_resource_group.openshift.name}"
  loadbalancer_id         = "${azurerm_lb.infra.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.infra.id}"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "default"
}

resource "azurerm_network_security_group" "infra" {
  name                = "openshift-infrastructure-security-group"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
}

resource "azurerm_network_security_rule" "infra-http" {
  name                        = "infra-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = 80
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.openshift.name}"
  network_security_group_name = "${azurerm_network_security_group.infra.name}"
}

resource "azurerm_network_security_rule" "infra-https" {
  name                        = "infra-https"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 443
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.openshift.name}"
  network_security_group_name = "${azurerm_network_security_group.infra.name}"
}

resource "azurerm_network_interface" "infra" {
  count                     = 3
  name                      = "openshift-infrastructure-nic-${count.index}"
  location                  = "${var.azure_location}"
  resource_group_name       = "${azurerm_resource_group.openshift.name}"
  network_security_group_id = "${azurerm_network_security_group.infra.id}"

  ip_configuration {
    name                          = "default"
    subnet_id                     = "${azurerm_subnet.infra.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_storage_share" "infra" {
  name                 = "openshift-infrastructure-file-share"
  resource_group_name  = "${azurerm_resource_group.openshift.name}"
  storage_account_name = "${azurerm_storage_account.openshift.name}"
  quota = 50
}

resource "azurerm_virtual_machine" "infra" {
  count                 = 3
  name                  = "openshift-infrastructure-vm-${count.index}"
  location              = "${var.azure_location}"
  resource_group_name   = "${azurerm_resource_group.openshift.name}"
  network_interface_ids = ["${element(azurerm_network_interface.infra.*.id, count.index)}"]
  vm_size               = "${var.infra_vm_size}"
  availability_set_id   = "${azurerm_availability_set.infra.id}"

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_image_sku}"
    version   = "${var.os_image_version}"
  }

  storage_os_disk {
    name              = "openshift-infrastructure-vm-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "openshift-infrastructure-vm-data-disk-${count.index}"
    create_option     = "Empty"
    managed_disk_type = "Standard_LRS"
    lun               = 0
    disk_size_gb      = 20
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "infra${count.index}"
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

provider "azurerm" {
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  subscription_id = "${var.azure_subscription_id}"
  tenant_id       = "${var.azure_tenant_id}"
}

resource "azurerm_resource_group" "openshift" {
  name     = "${var.resource_group_name}"
  location = "${var.azure_location}"
}

resource "azurerm_storage_account" "openshift" {
  name                = "openshift${lower(replace(substr(uuid(), 0, 10), "-", ""))}"
  resource_group_name = "${azurerm_resource_group.openshift.name}"
  location            = "${var.azure_location}"
  account_type        = "Standard_LRS"
  lifecycle {
      ignore_changes      = ["name"]
  }
}

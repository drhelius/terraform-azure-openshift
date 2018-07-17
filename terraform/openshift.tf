provider "azurerm" {
}

resource "azurerm_resource_group" "openshift" {
  name     = "${var.azure_resource_group_name}"
  location = "${var.azure_location}"
}

resource "azurerm_storage_account" "openshift" {
  name                      = "openshift${lower(replace(substr(uuid(), 0, 10), "-", ""))}"
  resource_group_name       = "${azurerm_resource_group.openshift.name}"
  location                  = "${var.azure_location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  lifecycle {
      ignore_changes        = ["name"]
  }
}

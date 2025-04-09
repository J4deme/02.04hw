provider "azurerm" {
  features {}
  subscription_id = "8e5cee5e-682c-43c3-aceb-7a8718a46c2e"
  tenant_id       = "c637c898-1476-4473-9714-dea70ac3e99e"
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-rg"
  location = "westeurope"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstatestrexamplesol"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}

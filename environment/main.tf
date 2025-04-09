resource "azurerm_resource_group" "main_rsg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "first-vnet" {
  name                = "first-vnet"
  resource_group_name = azurerm_resource_group.main_rsg.name
  location            = azurerm_resource_group.main_rsg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default-subnet" {
  name                 = "default-subnet"
  resource_group_name  = azurerm_resource_group.main_rsg.name
  virtual_network_name = azurerm_virtual_network.first-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
}

resource "azurerm_app_service_plan" "first-plan" {
  name                = "first-plan"
  resource_group_name = azurerm_resource_group.main_rsg.name
  location            = azurerm_resource_group.main_rsg.location

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

resource "azurerm_app_service" "first-service" {
  name                = "first-service"
  resource_group_name = azurerm_resource_group.main_rsg.name
  location            = azurerm_resource_group.main_rsg.location
  app_service_plan_id = azurerm_app_service_plan.first-plan.id

  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = "${azurerm_application_insights.first-insights.instrumentation_key}"
  }
}

resource "azurerm_application_insights" "first-insights" {
  name                = "first-insights"
  resource_group_name = azurerm_resource_group.main_rsg.name
  location            = azurerm_resource_group.main_rsg.location
  application_type    = "web"

}



resource "azurerm_container_registry" "first-container-registry" {
  name                = "examplesolcontainerregistry"
  resource_group_name = azurerm_resource_group.main_rsg.name
  location            = azurerm_resource_group.main_rsg.location
  sku                 = var.acr_sku

}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_app_service.first-service.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.first-container-registry.id
}



resource "azurerm_mssql_server" "first-mssql-server" {
  name                         = "first-mssql-serverexamplesol-439"
  resource_group_name          = azurerm_resource_group.main_rsg.name
  location                     = "West US"
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "first-mssql-db" {
  name         = "first-mssql-db"
  server_id    = azurerm_mssql_server.first-mssql-server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = var.sql_database_sku
  enclave_type = "VBS"

  tags = {
    foo = "bar"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_private_endpoint" "sql" {
  name                = "sql-pe"
  location            = azurerm_resource_group.main_rsg.location
  resource_group_name = azurerm_resource_group.main_rsg.name
  subnet_id           = azurerm_subnet.default-subnet.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.first-mssql-server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}
data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "main" {
  name                = "mainkeyvaultexamplesol"
  location            = azurerm_resource_group.main_rsg.location
  resource_group_name = azurerm_resource_group.main_rsg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.default-subnet.id]
  }
}

resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_app_service.first-service.identity[0].principal_id

  secret_permissions = ["Get"]
}

resource "azurerm_storage_account" "main" {
  name                      = var.storage_account_name
  resource_group_name       = azurerm_resource_group.main_rsg.name
  location                  = var.location
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication
  enable_https_traffic_only = true
}

resource "azurerm_storage_share" "fileshare" {
  name                 = var.storage_share_name
  storage_account_name = azurerm_storage_account.main.name
  quota                = 50
}

resource "azurerm_private_endpoint" "storage" {
  name                = "storage-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.main_rsg.name
  subnet_id           = azurerm_subnet.default-subnet.id

  private_service_connection {
    name                           = "storage-connection"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

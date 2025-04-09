output "app_service_url" {
  value = azurerm_app_service.first-service.default_site_hostname
}

output "application_insights_key" {
  value     = azurerm_application_insights.first-insights.instrumentation_key
  sensitive = true
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.first-mssql-server.fully_qualified_domain_name
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

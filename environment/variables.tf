variable "location" {
  description = "Azure region"
  default     = "westeurope"
}

variable "resource_group_name" {
  default = "main-resources"
}

variable "sql_admin_username" {
  default = "example-sol-admin"
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "app_service_plan_tier" {
  default = "Standard"
}

variable "app_service_plan_size" {
  default = "S1"
}

variable "acr_sku" {
  default = "Standard"
}

variable "key_vault_name" {
  default = "mainkeyvault123"
}

variable "sql_server_name" {
  default = "main-sql-server"
}

variable "sql_database_name" {
  default = "main-db"
}

variable "sql_database_sku" {
  default = "S0"
}

variable "storage_account_name" {
  default = "mainstorageacct123"
}

variable "storage_account_tier" {
  default = "Standard"
}

variable "storage_account_replication" {
  default = "LRS"
}

variable "storage_share_name" {
  default = "appshare"
}

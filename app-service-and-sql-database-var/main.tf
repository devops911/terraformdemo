# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "8690ba9a-5388-4b31-90df-15acb9170e0e"
  client_id       = "2b45f200-78e4-47b8-8f17-54141d6bc54b"
  client_secret   = "P_Mei_4CJ5pzwpVvCCj89StIFWvIgG4lmp"
  tenant_id       = "97bc43fb-b749-4757-955f-8167fc70e670"
  features {}
}
 


resource "azurerm_resource_group" "RG-Terraform" {
  name     = "terraform-resource-group"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "ASP-TerraForm" {
  name                = "terraform-appserviceplan"
  location            = azurerm_resource_group.RG-Terraform.location
  resource_group_name = azurerm_resource_group.RG-Terraform.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "AS-Terraform" {
  name                = "app-service-terraform"
  location            = azurerm_resource_group.RG-Terraform.location
  resource_group_name = azurerm_resource_group.RG-Terraform.name
  app_service_plan_id = azurerm_app_service_plan.ASP-TerraForm.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.test.fully_qualified_domain_name} Database=${azurerm_sql_database.test.name};User ID=${azurerm_sql_server.test.administrator_login};Password=${azurerm_sql_server.test.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "test" {
  name                         = "terraform-sqlserver2"
  resource_group_name          = azurerm_resource_group.RG-Terraform.name
  location                     = azurerm_resource_group.RG-Terraform.location
  version                      = "12.0"
  administrator_login          = "houssem"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_database" "test" {
  name                = "terraform-sqldatabase"
  resource_group_name = azurerm_resource_group.RG-Terraform.name
  location            = azurerm_resource_group.RG-Terraform.location
  server_name         = azurerm_sql_server.test.name

  tags = {
    environment = "production"
  }
}

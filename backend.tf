terraform {
  backend "azurerm" {
    resource_group_name     = "tf2022demo-rg"
    storage_account_name    = "bgzbtfstate"
    container_name          = "bgzbtfstatecont"
    key                     = "tfstate"  
  }
}
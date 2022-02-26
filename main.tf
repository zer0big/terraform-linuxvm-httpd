terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.98.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create the network VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

# Create a subnet for VM
resource "azurerm_subnet" "vm-subnet" {
  name                 = "vm-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

# Create an NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Get a Static Public IP
resource "azurerm_public_ip" "linux-vm-ip" {
  depends_on          = [azurerm_resource_group.rg]
  name                = var.hostname
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Card for linux VM
resource "azurerm_network_interface" "nic" {
  depends_on          = [azurerm_resource_group.rg]
  name                = "nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux-vm-ip.id
  }
}


data "azurerm_client_config" "current" {}

# Pull existing Key Vault from Azure
data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.kv_rgname
}

data "azurerm_key_vault_secret" "kv_secret" {
  name         = var.kv_secretname
  key_vault_id = data.azurerm_key_vault.kv.id
}

/*
# Assign UAI to KV access policy
resource "azurerm_key_vault_access_policy" "kvaccess" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List",
  ]

  secret_permissions = [
    "Get", "List",
  ]

}
*/

# Create Linux VM with linux server
resource "azurerm_linux_virtual_machine" "linux-vm" {
  depends_on            = [azurerm_network_interface.nic]
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  name                  = var.hostname
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "${var.hostname}_osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = var.hostname
  admin_username = var.admin_username
  //admin_password = var.admin_password
  admin_password                  = data.azurerm_key_vault_secret.kv_secret.value
  custom_data                     = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  disable_password_authentication = false
}

# Template for bootstrapping
data "template_file" "linux-vm-cloud-init" {
  template = file("azure-user-data.sh")
}

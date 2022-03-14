variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "bgzbtf"
}
 
variable "resource_group_name" {
  description = "The name of the Resource Group."
  default     = "rg-tfdemo"
}
 
variable "location" {
  description = "The region where the resoruces are provisoned."
  default     = "koreacentral"
}
 
variable "virtual_network_name" {
  description = "Virtual network name for the VM."
  default     = "vnet4web"
}
 
variable "subnet_name" {
  description = "Sub network name for the VM."
  default     = "subnet4webvm"
}
 
variable "hostname" {
  description = "Virtual machine hostname. Used for local hostname, DNS, and storage-related names."
  default     = "tf-linuxvm-httpd"
}
 
variable "pubip_name" {
  description = "Public IP name for the VM."
  default     = "pip4webvm"
}
 
variable "nic_name" {
  description = "NIC name for the VM."
  default     = "nic4webvm"
}
 
variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_v2"
}
 
variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "OpenLogic"
}
 
variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "CentOS"
}
 
variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "7_9-gen2"
}
 
variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "latest"
}
 
variable "admin_username" {
  description = "Administrator user name"
  default     = "zerobig"
}
 
variable "kv_name" {
  description = "Azure Key Valut name"
  default     = "kv4lds"
}
 
variable "kv_rgname" {
  description = "Azure Key Valut RG name"
  default     = "rg-lds-zerobig"
}
 
variable "kv_secretname" {
  description = "Azure Key Valut Secret name"
  default     = "linuxvmpw"
}
 
/*
variable "admin_password" {
  description = "Administrator password"
  default     = ""
}
*/
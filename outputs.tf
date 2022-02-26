output "vm_name" {
    description = "Public IP of the VM"
    value = azurerm_linux_virtual_machine.linux-vm.computer_name
}

output "vm_pip" {
    description = "Public IP of the VM"
    value = azurerm_linux_virtual_machine.linux-vm.public_ip_address
}

output "test_url" {
    description = "Vertiy the result of the provision"
    value = "start http://${azurerm_linux_virtual_machine.linux-vm.public_ip_address}"
}
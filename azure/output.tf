output "resource_group_name" {
  value = azurerm_resource_group.az_rg.name
}

output "http" {
  value = "http://${azurerm_linux_virtual_machine.az_vm.public_ip_address}"
}

output "ssh" {
  value = "ssh -i ${var.private_ssh_key} azureuser@${azurerm_linux_virtual_machine.az_vm.public_ip_address}"
}

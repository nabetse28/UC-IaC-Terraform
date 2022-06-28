# Create a resource group that will contain all the resources (vm, vnet, subnet, etc)
resource "azurerm_resource_group" "az_rg" {
  name     = "terraform-rg"
  location = "West US"
}

# Create virtual network
resource "azurerm_virtual_network" "az_vnet" {
  name                = "terraform-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
}

# Create subnet
resource "azurerm_subnet" "az_subnet" {
  name                 = "terraform-subnet1"
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "az_publicip" {
  name                = "terraform-publicip"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "az_net_sg" {
  name                = "terraform-securitygroup"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP_ACCESS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "az_netint" {
  name                = "terraform-networkinterface"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  ip_configuration {
    name                          = "terraform-niconf"
    subnet_id                     = azurerm_subnet.az_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az_publicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "az_net_int_sg_association" {
  network_interface_id      = azurerm_network_interface.az_netint.id
  network_security_group_id = azurerm_network_security_group.az_net_sg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "az_vm" {
  name                  = "terraform-VM"
  location              = azurerm_resource_group.az_rg.location
  resource_group_name   = azurerm_resource_group.az_rg.name
  network_interface_ids = [azurerm_network_interface.az_netint.id]
  size                  = "Standard_F2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "terraformvm"
  admin_username = "azureuser"
  #   disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  user_data = "IyEvYmluL2Jhc2gKIyBVc2UgdGhpcyBmb3IgeW91ciB1c2VyIGRhdGEgKHNjcmlwdCBmcm9tIHRvcCB0byBib3R0b20pCiMgaW5zdGFsbCBodHRwZCAoTGludXggMiB2ZXJzaW9uKQp5dW0gdXBkYXRlIC15Cnl1bSBpbnN0YWxsIC15IGh0dHBkCnN5c3RlbWN0bCBzdGFydCBodHRwZApzeXN0ZW1jdGwgZW5hYmxlIGh0dHBkCmVjaG8gIjxoMT5IZWxsbyBXb3JsZCBmcm9tICQoaG9zdG5hbWUgLWYpPGgxPiIgPiAvdmFyL3d3dy9odG1sL2luZGV4Lmh0bWw="

}

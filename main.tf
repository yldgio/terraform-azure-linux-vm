terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.name_prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}vnet"
  location            = var.location
  address_space       = [var.vnet_address_space]
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [var.subnet_address_space]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "rulessh" {
  name                        = "${var.name_prefix}rulessh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_interface" "nic" {
  name                      = "${var.name_prefix}nic"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.name_prefix}ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  depends_on = [azurerm_network_security_group.nsg]
}
resource "azurerm_network_interface_security_group_association" "nsgnic" {
  network_interface_id          = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_public_ip" "pip" {
  name                         = "${var.name_prefix}-ip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg.name
  domain_name_label            = var.hostname
  allocation_method            = "Dynamic"
}

# resource "azurerm_storage_account" "stor" {
#   name                = "${var.hostname}stor"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg.name
#   account_type        = var.storage_account_type
# }

# resource "azurerm_storage_container" "storc" {
#   name                  = "${var.name_prefix}-vhds"
#   resource_group_name   = azurerm_resource_group.rg.name
#   storage_account_name  = azurerm_storage_account.stor.name
#   container_access_type = "private"
# }

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.name_prefix}vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  computer_name         = var.hostname
  disable_password_authentication = var.disable_password_authentication
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }
  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
  os_disk  {
      caching              = "ReadWrite"
      name                 = "${var.name_prefix}vm-disk"
      storage_account_type = "Standard_LRS"   
  }
  depends_on            = [azurerm_network_interface.nic]
}

resource "azurerm_virtual_machine_extension" "msextension" {
  name                 = "${var.name_prefix}-ext-linuxagent"
  # location             = var.location
  # resource_group_name  = var.resource_group_name
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  depends_on           = [azurerm_linux_virtual_machine.vm]
  auto_upgrade_minor_version = true
  protected_settings = <<PROTECTED_SETTINGS
    {
        "script": "${base64encode(templatefile("centos-php.sh", {
          devops_url=var.devops_url, 
          pat=var.pat, 
          pool=var.pool, 
          agent=var.agent, 
          admin_user=var.admin_username, 
          AGENTRELEASE=var.agent_rel,
          agent_dist=var.agent_dist
          }))}"
    }
    PROTECTED_SETTINGS

}
output "admin_username" {
  value = var.admin_username
}

output "vm_fqdn" {
  value = azurerm_public_ip.pip.fqdn
}

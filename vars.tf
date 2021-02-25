# required variables
variable "hostname" {
  description = "name of the machine to create"
  default = "centos-7"
}

variable "name_prefix" {
  description = "unique part of the name to give to resources"
  default = "az-hosted"
}

variable "ssh_public_key" {
  description = "public key for ssh access"
}

# optional variables
variable "location" {
  description = "region where the resources should exist"
  default     = "westeurope"
}

variable "vnet_address_space" {
  description = "full address space allowed to the virtual network"
  default     = "10.0.0.0/16"
}

variable "subnet_address_space" {
  description = "the subset of the virtual network for this subnet"
  default     = "10.0.10.0/24"
}

variable "storage_account_type" {
  description = "type of storage account"
  default     = "Standard_LRS"
}

variable "vm_size" {
  description = "size of the vm to create"
  default     = "Standard_A0"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "OpenLogic"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "CentOS"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "7.5"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
}

variable "disable_password_authentication" {
  description = "toggle for password auth (recommended to keep disabled)"
  default     = false
}

#Replace [Organization] https://dev.azure.com/[Organization]/_usersSettings/tokens
variable "devops_url" {
  description = "Specify the Azure DevOps url e.g. https://dev.azure.com/mmelcher"
}

#Create via https://dev.azure.com/[Organization]/_usersSettings/tokens
variable "pat" {
  description = "Provide a Personal Access Token (PAT) for Azure DevOps"
}

#The build agent pool. Create it via https://dev.azure.com/[Organization]/_settings/agentpools?poolId=8&_a=agents
variable "pool" {
  description = "Specify the name of the agent pool - must exist before"
}

#The name of the agent
variable "agent" {
  description = "Specify the name of the agent"
}

#             vsts-agent-{linux-x64}-2.182.1.tar.gz
variable "agent_dist" {
  description = "Specify dist of the agent: vsts-agent-{linux-x64}-2.182.1.tar.gz"
  default = "linux-x64"
}
#             vsts-agent-linux-x64-{2.182.1}.tar.gz
variable "agent_rel" {
  description = "Specify the version of the agent: vsts-agent-linux-x64-{2.182.1}.tar.gz"
  default = "2.182.1"
}

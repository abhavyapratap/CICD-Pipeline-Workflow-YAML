module "vnet" {
  source              = "../../modules/azurerm_vnet"
  vnet_name           = "V-Net"
  resource_group_name = "rg-demon-slayer"
  location            = "centralindia"
  address_space       = ["10.0.0.0/16"]
}

module "subnet" {
  depends_on           = [module.vnet]
  source               = "../../modules/azurerm_subnet"
  subnet_name          = "frontend-subnet"
  resource_group_name  = "rg-demon-slayer"
  virtual_network_name = "V-Net"
  address_prefixes     = ["10.0.0.0/24"]
}

module "subnet1" {
  depends_on           = [module.vnet]
  source               = "../../modules/azurerm_subnet"
  subnet_name          = "backend-subnet"
  resource_group_name  = "rg-demon-slayer"
  virtual_network_name = "V-Net"
  address_prefixes     = ["10.0.1.0/24"]
}

module "nic" {
  depends_on            = [module.subnet]
  source                = "../../modules/azurerm_nic"
  nic_name              = "frontend-nic"
  location              = "centralindia"
  resource_group_name   = "rg-demon-slayer"
  ip_configuration_name = "configuration1"
  subnet_name           = "frontend-subnet"
  virtual_network_name  = "V-Net"
}

module "nic1" {
  depends_on            = [module.subnet1]
  source                = "../../modules/azurerm_nic"
  nic_name              = "backend-nic"
  location              = "centralindia"
  resource_group_name   = "rg-demon-slayer"
  ip_configuration_name = "configuration2"
  subnet_name           = "backend-subnet"
  virtual_network_name  = "V-Net"
}

module "pip" {
  depends_on          = [module.vnet]
  source              = "../../modules/azurerm_pip"
  pip_name            = "frontend-pip"
  resource_group_name = "rg-demon-slayer"
  location            = "centralindia"
}

module "pip1" {
  depends_on          = [module.vnet]
  source              = "../../modules/azurerm_pip"
  pip_name            = "backend-pip"
  resource_group_name = "rg-demon-slayer"
  location            = "centralindia"
}

module "nsg" {
  depends_on              = [module.vnet]
  source                  = "../../modules/azurerm_nsg"
  nsg_name                = "frontend-network-security-group"
  location                = "centralindia"
  resource_group_name     = "rg-demon-slayer"
  security_rule_name      = "test12"
  destination_port_ranges = ["22", "80"]
}

module "nsg1" {
  depends_on              = [module.vnet]
  source                  = "../../modules/azurerm_nsg"
  nsg_name                = "backend-network-security-group"
  location                = "centralindia"
  resource_group_name     = "rg-demon-slayer"
  security_rule_name      = "test21"
  destination_port_ranges = ["22", "8000"]
}

module "vm" {
  depends_on          = [module.nic]
  source              = "../../modules/azurerm_vm"
  vm_name             = "Frontend-VM"
  resource_group_name = "rg-demon-slayer"
  location            = "centralindia"
  size                = "Standard_B2s"
  os_disk_name        = "frontend-os-disk"
  publisher           = "Canonical"
  offer               = "0001-com-ubuntu-server-jammy"
  sku                 = "22_04-lts"
  version1            = "latest"
  key_name            = "demons-safe-house"
  username_secret_key = "frontend-vm-username"
  pwd_secret_key      = "frontend-vm-pwd"
  nic_name            = "frontend-nic"
}

module "vm1" {
  depends_on          = [module.nic1]
  source              = "../../modules/azurerm_vm"
  vm_name             = "Backend-VM"
  resource_group_name = "rg-demon-slayer"
  location            = "centralindia"
  size                = "Standard_B2s"
  os_disk_name        = "backend-os-disk"
  publisher           = "Canonical"
  offer               = "0001-com-ubuntu-server-focal"
  sku                 = "20_04-lts"
  version1            = "latest"
  key_name            = "demons-safe-house"
  username_secret_key = "backend-vm-username"
  pwd_secret_key      = "backend-vm-pwd"
  nic_name            = "backend-nic"
}

module "server" {
  depends_on                   = [module.vnet]
  source                       = "../../modules/azurerm_mssql_server"
  server_name                  = "indianserver"
  resource_group_name          = "rg-demon-slayer"
  location                     = "centralindia"
  version-new                  = "12.0"
  key_name                     = "demons-safe-house"
  database_username_secret_key = "mssql-database-username"
  database_pwd_secret_key      = "mssql-database-pwd"
}

module "database" {
  depends_on          = [module.server]
  source              = "../../modules/azurerm_mssql_database"
  database_name       = "indiandatabase"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  license_type        = "LicenseIncluded"
  max_size_gb         = 2
  sku_name            = "S0"
  enclave_type        = "VBS"
  server_name         = "indianserver"
  resource_group_name = "rg-demon-slayer"
}
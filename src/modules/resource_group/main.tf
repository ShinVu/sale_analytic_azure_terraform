### Resource group ###
# Generate a random name for resource group
resource "random_pet" "rg_name" {
  prefix = var.prefix # Prefix with variable var.resource_group_name_prefix
}

# Create resource group 
resource "azurerm_resource_group" "rg" {
  location = var.location          # Location of the resource group
  name     = random_pet.rg_name.id # Name of the resource group
}


# We allow for existing resource groups or we can create one automatically. 
# Use the should_create_rg variable to control this behavior.
resource "azurerm_resource_group" "deployment-rg" {
  count    = var.should_create_rg == true ? 1 : 0
  name     = local.rg.name
  location = local.rg.location
}

data azurerm_resource_group "rg" {
  depends_on = [ azurerm_resource_group.deployment-rg ]
  name = local.rg.name
}

resource "azurerm_management_lock" "rg_lock" {
  count      = var.env == "prod" && var.should_create_rg ? 1 : 0
  name       = "${local.rg.name}-lock"
  scope      = data.azurerm_resource_group.rg.id
  lock_level = "CanNotDelete"
  notes      = "This lock prevents deletion of the resource group."
}

resource "azurerm_role_assignment" "crnt_usr_vnet_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.usr.object_id

  description = "VNet Contributor for IaC user context"
}

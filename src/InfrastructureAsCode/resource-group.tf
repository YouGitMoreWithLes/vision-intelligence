

resource "azurerm_resource_group" "deployment-rg" {
  count    = var.should_create_rg == true ? 1 : 0
  name     = local.rg.name
  location = local.rg.location
}

resource "azurerm_management_lock" "rg_lock" {
  count      = var.env == "prod" ? 1 : 0
  name       = "${local.rg.name}-lock"
  scope      = azurerm_resource_group.deployment-rg[0].id
  lock_level = "CanNotDelete"
  notes      = "This lock prevents deletion of the resource group."
}

resource "azurerm_role_assignment" "crnt_usr_vnet_contributor" {
  scope                = azurerm_resource_group.deployment-rg[0].id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.usr.object_id

  description = "VNet Contributor for IaC user context"
}

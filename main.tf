module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "~> 5.2.0"

  disable_telemetry = true

  default_location = var.default_location
  root_parent_id   = var.root_parent_management_group_id == "" ? data.azurerm_client_config.current.tenant_id : var.root_parent_management_group_id

  deploy_corp_landing_zones    = true
  deploy_management_resources  = true
  deploy_online_landing_zones  = true
  root_id                      = var.root_id
  root_name                    = var.root_name
  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_identity     = var.subscription_id_identity
  subscription_id_management   = var.subscription_id_management
  archetype_config_overrides = local.archetype_config_overrides
  library_path   = "${path.root}/lib"

custom_landing_zones = {
    "${var.root_id}-online-example-1" = {
      display_name               = "${upper(var.root_id)} Online Example 1"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "customer_online"
        parameters     = {}
        access_control = {}
      }
    }

    "${var.root_id}-online-example-2" = {
      display_name               = "${upper(var.root_id)} Online Example 2"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "customer_online"
        parameters = {
          Deny-Resource-Locations = {
            listOfAllowedLocations = ["northeurope","westeurope" ]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["northeurope","westeurope" ]
          }
        }
        access_control = {}
      }
    }

    "${var.root_id}-sandboxes-example-1" = {
      display_name               = "${upper(var.root_id)} AppTeam 1 Sandbox"
      parent_management_group_id = "${var.root_id}-sandboxes"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "appteam1-sandbox"
        parameters     = {
        }
        access_control = {}
      }
    }

}
  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }
}

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

    # "${var.root_id}-sandboxes-example-1" = {
    #   display_name               = "${upper(var.root_id)} AppTeam 1 Sandbox"
    #   parent_management_group_id = "${var.root_id}-sandboxes"
    #   subscription_ids           = []
    #   archetype_config = {
    #     archetype_id   = "appteam1-sandbox"
    #     parameters     = {
    #     }
    #     access_control = {}
    #   }
    # }
    "${var.root_id}-sandboxes" = {
      display_name               = "Sandboxes"
      parent_management_group_id = "${var.root_id}"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "sandboxes"
        parameters     = {
        }
        access_control = {}
      }
    }
}

module "hub_and_spoke" {
  source  = "Azure/caf-enterprise-scale/azurerm/modules/connectivity"
  version = "~> 5.2.0"

  root_parent_id = module.enterprise_scale.root_id
  location       = var.default_location
  subscription_id_connectivity = var.subscription_id_connectivity

  hub_network_config = {
    address_space = ["10.0.0.0/16"]
    subnets = {
      gateway_subnet = { address_prefix = "10.0.1.0/24" }
      firewall_subnet = { address_prefix = "10.0.2.0/24" }
      default_subnet = { address_prefix = "10.0.3.0/24" }
    }
  }

  spoke_networks = [
    {
      name            = "spoke1"
      address_space   = ["10.1.0.0/16"]
      subscription_id = var.spoke1_subscription_id
    },
    {
      name            = "spoke2"
      address_space   = ["10.2.0.0/16"]
      subscription_id = var.spoke2_subscription_id
    }
  ]
}
  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }
}

resource "azurerm_databricks_workspace" "dbw" {
    count               = var.should_deploy_databricks_resources ? 1 : 0

    name                = format("%s-%s", local.base-name, "dbw")
    resource_group_name = data.azurerm_resource_group.rg.name
    location            = data.azurerm_resource_group.rg.location
    sku                 = var.databrick_sku

    managed_resource_group_name = format("%s-%s", local.base-name, "dbw-mngd-rg")

    tags = data.azurerm_resource_group.rg.tags
}

resource "databricks_dbfs_file" "init_script" {
    count               = var.should_deploy_databricks_resources ? 1 : 0
    
    depends_on = [azurerm_databricks_workspace.dbw[0]]

    //source          = pathexpand(var.cluster1_init_script_name)
    content_base64  = filebase64(pathexpand(var.cluster1_init_script_name))
    path            = format("%s/%s", var.cluster1_init_script_path, var.cluster1_init_script_name)
}

# data "databricks_node_type" "smallest" {
#   local_disk = true
# }

# data "databricks_spark_version" "latest_lts" {
#   long_term_support = true
# }

resource "databricks_cluster" "cluster1" {
    count               = var.should_deploy_databricks_resources ? 1 : 0

    depends_on = [
        azurerm_databricks_workspace.dbw[0],
        databricks_dbfs_file.init_script[0]
    ]

    cluster_name            = var.cluster1_name
    spark_version           = var.cluster1_spark_version
    node_type_id            = var.cluster1_node_type_id
    driver_node_type_id     = var.cluster1_driver_node_type_id

    autotermination_minutes = var.cluster1_auto_terminate
    # num_workers             = 8

    autoscale {
        min_workers = var.cluster1_min_workers
        max_workers = var.cluster1_max_workers
    }

    spark_conf = {
        "spark.databricks.io.cache.enabled": true
        "spark.databricks.delta.schema.autoMerge.enabled": true
        "spark.databricks.delta.preview.enabled": true
        "spark.sql.autoBroadcastJoinThreshold": -1
        "spark.driver.maxResultSize": "8g"
    }

    dynamic "library" {
        for_each = var.cluster1_py_libraries
        content {
            pypi {
                package = library.value
            }
        }
    }

    # init_scripts {
    #     dbfs {
    #         destination = format("dbfs:%s", databricks_dbfs_file.init_script.path)
    #     }
    # }

    spark_env_vars = {
        "PYSPARK_PYTHON":"/databricks/python3/bin/python3"
    }

    custom_tags = data.azurerm_resource_group.rg.tags
}

resource "null_resource" "databricks_pat" {
    count               = var.should_deploy_databricks_resources ? 1 : 0

    depends_on = [ azurerm_databricks_workspace.dbw[0] ]

    triggers  =  { always_run = timestamp() }

    provisioner "local-exec" {
        command = "chmod +x ./generate-pat-token.sh && ./generate-pat-token.sh"

        environment = {
            RESOURCE_GROUP = data.azurerm_resource_group.rg.name
            DATABRICKS_WORKSPACE_RESOURCE_ID = azurerm_databricks_workspace.dbw[0].id
            KEY_VAULT = azurerm_key_vault.key-vault.name
            SECRET_NAME = "sec-databricks-access-token"
            DATABRICKS_ENDPOINT = "https://${azurerm_databricks_workspace.dbw[0].workspace_url}"
            # ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID are already
            # present in the environment if you are using the Terraform
            # extension for Azure DevOps or the starter from
            # https://github.com/algattik/terraform-azure-pipelines-starter.
            # Otherwise, provide them as additional variables.
        }
    }
}

resource "databricks_secret_scope" "kv" {
    count               = var.should_deploy_databricks_resources ? 1 : 0

    depends_on = [
        azurerm_databricks_workspace.dbw[0],
        azurerm_key_vault.key-vault,
        null_resource.databricks_pat[0]
    ]

    name = var.databricks_secret_scope

    keyvault_metadata {
        resource_id = azurerm_key_vault.key-vault.id
        dns_name = azurerm_key_vault.key-vault.vault_uri
    }
}

# For non native (hashicorp) provider, each module should have it own required providers as Terraform does not automatically map them. 
# For configurations on each provider, please make configuration in the root module. Then explicitly pass providers and define configuration aliases.
# Check https://developer.hashicorp.com/terraform/language/modules/develop/providers
terraform {
  required_providers {
    #Databricks provider for interacting with azure databricks
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace, databricks.account]
    }
  }
}


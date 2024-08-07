terraform {
  required_version = ">= 1.9"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.14"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.71"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

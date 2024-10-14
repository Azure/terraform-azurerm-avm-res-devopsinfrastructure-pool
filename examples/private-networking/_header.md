# Example of deploying DevOps Managed Pools with Private Networking

>**⚠️WARNING!⚠️**: THIS IS A PREVIEW SERVICE, MICROSOFT MAY NOT PROVIDE SUPPORT FOR THIS, PLEASE CHECK THE PRODUCT DOCS FOR CLARIFICATION

This deploys the module with Private Networking for Azure Managed DevOps Pools.

There are some points of note for this example:

- There is a special built in service principal called `DevOpsInfrastructure` that is used to join the Managed DevOps Pool to the Virtual Network Subnet. This service principal must be granted role assignments to the virtual network and subnet for this to work. You can read more here: <https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-networking?view=azure-devops&tabs=azure-portal#to-check-the-devopsinfrastructure-principal-access>
- In the example we have created a custom role in order to demonstrate least privilege access, but you can also use the built in `Network Contributor` role.

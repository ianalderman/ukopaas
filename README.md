If you choose to use Bring Your Own Key (BYOK) you will need an existing key in a Key Vault.  For testing purposes you can use the commands below to create a suitable key:

az keyvault key create --vault-name $vaultName --name $keyName --size 2048 --protection software
az keyvault key show --vault-name $vaultName --name $keyName --query key.kid


# Solution Overview
For more information about this solution, see [Azure Security and Compliance Blueprint - UK-OFFICAL Three-Tier Web Applications using Platform as a Service](https://aka.ms/??).

# Deploy the Solution

These templates automatically deploy the Azure resources for a Windows based three-tier application with an Active Directory Domain architecture. **As this is a complex deployment that delivers the full infrastructure and environment, it can take up to two hours to deploy using the Azure Portal (Method 2).** Progress can be monitored from the Resource Group blade and Deployment output blade in the Azure Portal.

There are two methods that deployment users may use to deploy this reference architecture. The first method uses a Bash script, whereas the second method utilises Azure Portal to deploy the reference architecture. These two methods are detailed in the sections below.

 As a pre-requisite to deployment, users should ensure that they have:

- An Azure Subscription
- Contributor or Owner rights to the Subscription

> If you would like to configure an Azure Active Directory Group as part of the scripted deployment you will need to have suitable permissions within your Azure Active Directory.

Other Azure architectural best practices and guidance can be found in [Azure Reference Architectures](https://docs.microsoft.com/azure/guidance/guidance-architecture). Supporting Microsoft Visio templates are available from the [Microsoft download center](http://download.microsoft.com/download/1/5/6/1569703C-0A82-4A9C-8334-F13D0DF2F472/RAs.vsdx) with the corresponding ARM Templates found at [Azure Reference Architectures ARM Templates](https://github.com/mspnp/reference-architectures).

## Method 1: Azure CLI 2 (Express version)
To deploy this solution through the Azure CLI, you will need the latest version of the [Azure CLI 2](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) to use the BASH script that deploys the solution. Alternatively you can use the [Azure Cloud Shell](https://shell.azure.com/). To deploy the reference architecture, follow these steps:
1. Download the BASH script pre_reqs.sh, for example with the command ```wget https://raw.githubusercontent.com/ianalderman/ukopaas/master/scripts/pre_reqs.sh```
2. Execute the script by using the command ```bash pre_reqs.sh```
3. If you do not know the short name of the region you wish to deploy to enter ```Y``` else enter ```N```
4. Enter the short name of the region you wish to deploy to e.g. ```northeurope```

> Note: The parameter files include hard-coded passwords in various places. It is strongly recommended that you change these values.
> If the parameters files are not updated, the default values will be used which may not be compatible with your on-premises environment.

### Method 1a: Azure CLI 2 (Configuring the deployment via script arguments)
The ```pre_reqs.sh``` script supports a number of command line arguments that allow you to customise the deployment.  These are:

1. Region - should be a valid shortname for a region
2. Base Resource Name (used for uniqueness) - should be less than 15 chars and all lower case
3. Base Resource Group Name
4. SQL Admin configuration - valid options are ```Group```, ```User```, ```None```
5. Log Analytics SKU - valid options are ```Free``` or ```pergb2018```

>As the arguments are positional, rather than named you need to add them in the correct order.  If you specify arguments you don't have to specify all of them, for example you could provide just the first argument, or arguments 1,2 & 3.  You cannot supply them out of order.

```bash pre_reqs.sh northeurope paasbp rg-ne-paas-blueprint```

## Method 2: Azure Portal Deployment Process

A deployment for this reference architecture is available on
[GitHub](https://github.com/Azure/uk-official-three-tier-webapp). The templates can be cloned or downloaded if customisation of parameters is requried.
The reference architecture is deployed in three stages. To deploy the architecture, follow the steps below for each deployment stage.

For virtual machines, the parameter files include hard-coded administrator user names and passwords. These values can be changed in the parameter files if required. It is ***strongly recommended that you immediately change both on all the VMs***. Click on each VM in the Azure portal then click on **Reset password** in the **Support troubleshooting** blade.

## Stage 1: Deploy Networking Infrastructure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fuk-official-three-tier-webapp%2Fmaster%2Ftemplates%2Fvirtualnetwork.azuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

1. Click on the **Deploy to Azure** button to begin the first stage of the deployment. The link takes you to the Azure Portal.
2. Select **Create New** and enter a value such as `uk-official-networking-rg` in the **Resource group** textbox.
3. Select a region such as `UKSouth` or `UKWest`, from the **Location** drop down box. All Resource Groups required for this architecture should be in the same Azure region (e.g., `UKSouth` or `UKWest`).
4. Some parameters can be edited in the deployment page. For full compatibility with your on-premises environment, review the network parameters and customise your deployment, if necessary. If greater customisation is required, this can be done through cloning and editing the templates directly, or in situ by editing the templates by clicking 'Edit template'.
5. Review the terms and conditions, then click the **I agree to the terms and conditions stated above** checkbox.
6. Click on the **Purchase** button.
7. Check the Azure Portal notifications for a message stating that this stage of deployment is complete, and proceed to the next deployment stage if completed.
8. If for some reason your deployment fails, it is advisable to delete the resource group in its entirety to avoid incurring cost and orphan resources, fix the issue, and redeploy the resource groups and template.

## Stage 2: Deploy Active Directory Domain
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fuk-official-three-tier-webapp%2Fmaster%2Ftemplates%2Faads.azuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

1. Click on the **Deploy to Azure** button to begin the second stage of the deployment. The link takes you to the Azure Portal.
2. Select **Create New** and enter a value such as `uk-official-adds-rg` in the **Resource group** textbox.
3. Select a region such as `UKSouth` or `UKWest`, from the **Location** drop down box. All Resource Groups required for this architecture should be in the same Azure region (e.g., `UKSouth` or `UKWest`).
4. Some domain parameters will need to be edited in the deployment page, otherwise default example values will be used. For full compatibility with your on-premises environment, review the domain parameters and customise your deployment, if necessary. If greater customisation is required, this can be done through cloning and editing the templates directly, or in situ by editing the templates by clicking 'Edit template'.
5. In the **Settings** textboxes, enter the networking resource group as entered when creating the networking infrastructure in deployment step 1.
6. Enter the Domain settings and Admin credentials.
7. Review the terms and conditions, then click the **I agree to the terms and conditions stated above** checkbox.
8. Click on the **Purchase** button.
9. Check Azure Portal notifications for a message stating that this stage of deployment is complete, and proceed to the next deployment stage if completed.
10.	If for some reason your deployment fails, it is advisable to delete the resource group in its entirety to avoid incurring cost and orphan resources, fix the issue, and redeploy the resource groups and template.
Check Azure portal notification for a message that the stage of deployment is complete and move on to the next if completed.

> **Note**: The deployment includes default passwords if left unchanged. It is strongly recommended that you change these values.

![alt text](images/create-official-aads-rg.JPG?raw=true "Create ADDS deployment")

## Stage 3: Deploy Operational Workload Infrastructure
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fuk-official-three-tier-webapp%2Fmaster%2Ftemplates%2Fworkloads.azuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

1. Click on the **Deploy to Azure** button to begin the third stage of the deployment. The link takes you to the Azure Portal.
2. Select **Create New** and enter a value such as `uk-official-operational-rg` in the **Resource group** textbox.
3. Select a region, such as UKSouth or UKWest, from the Location drop down box. All Resource Groups required for this architecture should be in the same Azure region (e.g., `UKSouth` or `UKWest`).
4. Some parameters can be edited in the deployment page. If greater customisation is required, this can be done through cloning and editing the templates directly, or in situ by editing the templates by clicking 'Edit template'.
5. In the **Settings** textboxes, enter the operational network resource group as entered when creating the networking infrastructure in deployment step 1.
6. Enter the Virtual Machine Admin credentials.
7. Review the terms and conditions, then click the **I agree to the terms and conditions stated above** checkbox.
8. Click on the **Purchase** button.
9. Check Azure Portal notifications for a message stating that this stage of deployment is complete.
10. If for some reason your deployment fails, it is advisable to delete the resource group in its entirety to avoid incurring cost and orphan resources, fix the issue, and redeploy the resource groups and template.

> **Note**: The deployment includes default passwords if left unchanged. It is strongly recommended that you change these values.

![alt text](images/create-official-workload-rg.JPG?raw=true "Create ADDS deployment")

## Deployment and Configuration Activities
The table below provides additional information about deployment parameters, as well as other configuration steps related to the deployment activities.

  Activity|Configuration|
  ---|---
  Create Management VNet Resource Groups|Enter resource group name during deployment.
  Create Operational VNet Resource Groups|Enter resource group name during deployment.
  Deploy  VNet network infrastructure|Enter resource group name during deployment.
  Create VNet Peerings|None required.|
  Deploy VPN Gateway|The template deploys an Azure environment with a public facing endpoint and an Azure Gateway to allow VPN setup between the Azure environment and your on-premises environment. To complete this VPN connection, you will need to provide the Local Gateway (your on-premises VPN public IP address) and complete the VPN connection set up locally. VPN Gateway requires local gateway configuration in the [/parameters/azure/ops-network.parameters.json](/parameters/azure/ops-network.parameters.json) template parameters file  or through the Azure Portal.
  Deploying internet facing Application Gateway|For SSL termination, Application Gateway requires you SSL certificates to be uploaded. When provisioned, the Application Gateway will instantiate a public IP address and domain name to allow access to the web application.
  Create Network Security Groups for VNETs|RDP access to the management VNet Jumpbox must be secured to a trusted IP address range. It is important to amend the "sourceAddressPrefix" parameter with your own trusted source IP address range in the [/parameters/azure/nsg-rules.parameters.json](/parameters/azure/nsg-rules.parameters.json) template parameters file. NSG configuration for the operational VNet can be found at [/parameters/azure/ops-vent-nsgs.json](/parameters/azure/ops-vent-nsgs.json).
  Create ADDS resource group|Enter resource group name during deployment and edit the configuration fields if required.
  Deploying ADDS servers|None required.
  Updating DNS servers|None required.
  Create ADDS domain|The provided templates create a demo 'treyresearch' domain. To ensure that the required Active Directory Domain is created with the desired domain name and administrative user the fields can be configured in the deployment screen or the [/parameters/azure/add-adds-domain-controller.parameters.json](/parameters/azure/add-adds-domain-controller.parameters.json) template parameters file must be edited with the required values.
  Create ADDS domain controller|None required.
  Create operational workload Resource Group|Enter resource group name during deployment.
  Deploy operational VM tiers and load balancers   |None required.
  Set up IIS web server role for web tier|None required.
  Enable Windows Auth for VMs|None required.
  Deploy Microsoft Anti-malware to VMs|None required.
  Domain Join VMs|Domain joining the Virtual Machines is a post deployment step and must be **manually** completed.

# UK Government Private Network Connectivity

Microsoft's customers are able to use [private connections](https://news.microsoft.com/2016/12/14/microsoft-now-offers-private-internet-connections-to-its-uk-data-centres/#sm.0001dca7sq10r1couwf4vvy9a85zx)
to the Microsoft UK datacentres (UK West and UK South). Microsoft's partners a providing a gateway from PSN/N3 to [ExpressRoute](https://azure.microsoft.com/services/expressroute/) and into Azure, and this is just one of the new services the group has unveiled since Microsoft launched its [**Azure**](https://azure.microsoft.com/blog/) and Office 365 cloud offering in the UK. (https://news.microsoft.com/2016/09/07/not-publish-microsoft-becomes-first-company-open-data-centres-uk/). Since then, [**thousands of customers**](https://enterprise.microsoft.com/industries/public-sector/microsoft-uk-data-centres-continue-to-build-momentum/?wt.mc_id=AID563187_QSG_1236), including the Ministry of Defence, the Met Police, and parts of the NHS, have signed up to take advantage of the sites. These UK datacentres offer UK data residency, security and reliability.

# Cost

Deploying this template will create one or more Azure resources. You will be responsible for the costs generated by these resources, so it is important that you review the applicable pricing and legal terms associated with all resources and offerings deployed as part of this template. For cost estimates, you can use the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator).

# Further Reading



Best practices on Azure Network Security and a decision-making matrix can be found in [Microsoft cloud services and network security](https://docs.microsoft.com/azure/best-practices-network-security).

# Disclaimer

- This document is for informational purposes only. MICROSOFT MAKES NO WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, AS TO THE INFORMATION IN THIS DOCUMENT. This document is provided "as-is." Information and views expressed in this document, including URL and other Internet website references, may change without notice. Customers reading this document bear the risk of using it.  
- This document does not provide customers with any legal rights to any intellectual property in any Microsoft product or solutions.  
- Customers may copy and use this document for internal reference purposes.  
- Certain recommendations in this document may result in increased data, network, or compute resource usage in Azure, and may increase a customer's Azure license or subscription costs.  
- This architecture is intended to serve as a foundation for customers to adjust to their specific requirements and should not be used as-is in a production environment.
- This document is developed as a reference and should not be used to define all means by which a customer can meet specific compliance requirements and regulations. Customers should seek legal support from their organization on approved customer implementations.

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
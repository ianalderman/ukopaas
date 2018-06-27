#Request user region
#!/bin/bash

declare regionToDeployTo
declare baseName
declare rgBaseName
declare rgName
declare useAADGroup
declare upn
declare paramString
declare logAnalyticsSKU
declare aadUserId

#List of regions used to validate offered region
regions=$(az account list-locations --query "[].{displayname:displayname, shortname:name}"  --output tsv)

if [ $# -eq 0 ]; then
    echo -n "Would you like a list of regions to deploy to? Y/N (N):"
    read listlocations

    if [ $listlocations == "Y" -o $listlocations == "y" ]; then 
        az account list-locations --query "[].{displayname:displayname, shortname:name}"  --output table
    fi

    echo -n "Please enter the region you wish to deploy to (using the shortname):"
    read regionToDeployTo
    rgName="rg-paas-blueprint"
    useAADGroup=0
    else
        if [[ $regions == *"$1"* ]]; then
            regionToDeployTo=$1
        else
            echo -n "Unknown region - would you like a list of regions to deploy to? Y/N (N):"
            read listlocations

            if [ $listlocations == "Y" -o $listlocations == "y" ]; then 
                az account list-locations --query "[].{displayname:displayname, shortname:name}"  --output table;
            fi
        echo -n "Please enter the region you wish to deploy to (using the shortname):"
        read regionToDeployTo 
        fi

        if [ -z "$2" ]; then
            baseName=$(head -n 1 /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
        else
            baseName=$2
        fi

        if [ -z "$3" ]; then
            rgBaseName="rg-paas-blueprint"
        else
            rgBaseName=$3
        fi

        if [ -z "$4" ]; then
            useAADGroup=0
        else
            if [ "$4" == "Yes" ]; then
                useAADGroup=1
            else
                useAADGroup=0
            fi
        fi

        if [ -z "$5" ]; then
            echo "Attempting to identify Log Analytics available SKU...."
            token=$(az account get-access-token | jq ".accessToken" -r)
            subscriptionId=$(az account show | jq ".id" -r)
            optedIn=$(curl -X POST -H "Authorization:Bearer $token" -H "Content-Length:0" https://management.azure.com/subscriptions/$subscriptionId/providers/microsoft.insights/listmigrationdate?api-version=2017-10-01 | jq ".optedInDate" -r)
            echo "detected optedIn Date:$optedIn"

            if [[ $optedIn == "" ]]; then
                logAnalyticsSKU="pergb2018"
                echo "Log Analytics SKU set to pergb2018"
            else
                logAnalyticsSKU="Free"
                echo "Log Analytics SKU set to Free"
            fi
        else
            logAnalyticsSKU=$5
        fi
fi
LEN=$(echo ${#regionToDeployTo})

if [[ $regions != *"$regionToDeployTo"* ]] || [[ ${#regionToDeployTo} -lt 6 ]]; then
    echo "Unknown Region, exiting script"
    exit 1
fi



#Create deployment resource groups
echo "Creating resource groups"
baseResourceGroup=$(az group create -l $regionToDeployTo -n $rgBaseName)
appServiceResourceGroup=$(az group create -l $regionToDeployTo -n $rgBaseName-appService)
keyVaultResourceGroup=$(az group create -l $regionToDeployTo -n $rgBaseName-keyVault)
storageResourceGroup=$(az group create -l $regionToDeployTo -n $rgBaseName-storage)
azureSQLResourceGroup=$(az group create -l $regionToDeployTo -n $rgBaseName-azureSQL)

#ToDo: Check deployment succedded and extract details from output
#Assign current user to the SQL Administrators group (we do this after deployment to give the group a chance to be fully available...)
#Need to get AD USER Id not account user id.  If AD USer source = Microsoft Account then az accout show gives live.com#<u/name>, source "Windows Sevrer AD" gives email directly...
#UPN though is email for Windows Server AD and for Microsoft Account it is email address with @ replaced by _ then #EXT# emailaddress(no @).onmicrosoft.com
#e.g. me@outlook.com => me_outlook.com#EXT#@meoutlook.onmicrosoft.com (strips domain from email address in second half)
#az ad user show --upn-or-object-id UPN

#aadUserId=$(az account show | jq ".id" -r)
aadUserMail=$(az account show | jq ".user.name" -r)

if [[ $aadUserMail == *"live.com#"* ]]; then
    upn=$(echo $aadUserMail | cut -d '#' -f 2)
    upnLeft=$(echo ${upn/@/"_"})
    upnRight=$(echo $upnLeft | cut -d "." -f 1)
    upnRight=$(echo ${upnRight/_/""})
    upn="$upnLeft#EXT#@$upnRight.onmicrosoft.com"
    aadUserMail=$(echo $aadUserMail | cut -d '#' -f 2)
else   
    upn=$(echo $aadUserMail)
fi

aadUserId=$(az ad user show --upn-or-object-id $upn | jq ".objectId" -r)

if [ $useAADGroup -eq 1 ]; then
    
    echo "Creating AAD Group for SQL Admin"
    groupMail="paasblueprintsqladminss"
    groupName="PaaSBlueprintSQLAdministrators"
    
    #ToDo: Check if group exists, if so get the ObjectId rather than keep creating a new one...
    #aadGroupId=$(az ad group create --display-name "PaaS Blueprint SQL Administrators" --mail-nickname "paasblueprintsqladminss" | jq ".objectId" -r)
    aadGroupId=$(az ad group create --display-name "$groupName" --mail-nickname "$groupMail" | jq ".objectId" -r)
    paramString="appServiceResourceGroup=$rgBaseName-appService keyVaultResourceGroup=$rgBaseName-keyVault storageResourceGroup=$rgBaseName-storage azureSQLResourceGroup=$rgBaseName-azureSQL AADAdminLogin=$groupName AADAdminObjectID=$aadGroupId AlertSendToEmailAddress=$aadUserMail LogAnalyticsSKU=$logAnalyticsSKU"
    echo "Assigning logged in user to SQL Administrators Group"
    addUser=$(az ad group member add -g $aadGroupId --member-id $aadUserId)
else
    paramString="appServiceResourceGroup=$rgBaseName-appService keyVaultResourceGroup=$rgBaseName-keyVault storageResourceGroup=$rgBaseName-storage azureSQLResourceGroup=$rgBaseName-azureSQL AADAdminLogin=$upn AADAdminObjectID=$aadUserId AlertSendToEmailAddress=$aadUserMail useAADGroupForSQLAdmin=Yes LogAnalyticsSKU=$logAnalyticsSKU"
fi

#Run the deployment
echo "Starting deployment..."

deploymentOutput=$(az group deployment create -g $rgBaseName --template-uri https://raw.githubusercontent.com/ianalderman/ukopaas/master/v2/azuredeploy.json --parameters $paramString)

echo "Deployment completed..."

#To Do:Assign the MSI ID to SQL Server
#echo "Granting API App permissions in SQL Database..."
#sqlcmd -S <Servername>.database.windows.net -U <username> -P <password> -Q "GRANT " -o SQLOutput.txt
#Grep the SQLOutput for success
echo "Script finished"
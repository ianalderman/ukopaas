#Request user region
#!/bin/bash
regions=$(az account list-locations --query "[].{displayname:displayname, shortname:name}"  --output tsv)
declare regionToDeployTo

if [ $# -eq 0 ]; then
    echo -n "Would you like a list of regions to deploy to? Y/N (N):"
    read listlocations

    if [ $listlocations == "Y" -o $listlocations == "y" ]; then 
        az account list-locations --query "[].{displayname:displayname, shortname:name}"  --output table
    fi

    echo -n "Please enter the region you wish to deploy to (using the shortname):"
    read regionToDeployTo

    else
        if [ $regions =~ $1 ]; then
            regionToDeployTo=$1
        else
            echo -n "Unknown region - would you like a list of regions to deploy to? Y/N (N):"
            read listlocations

            if [ $listlocations == "Y" -o $listlocations == "y"]; then 
                az account list-locations --query "[].{displayname:displayname, shortname:name}"  --output table;
            fi
        echo -n "Please enter the region you wish to deploy to (using the shortname):"
        read regionToDeployTo 
        fi
fi
LEN=$(echo ${#regionToDeployTo})

if [[ $regions != *"$regionToDeployTo"* ]] || [[ ${#regionToDeployTo} -lt 6 ]]; then
    echo "Unknown Region, exiting script"
    exit 1
fi

#Create deployment resource groups
echo "Creating resource group"
rgName="rg-paas-blueprint"

resourceGroup=$(az group create -l $regionToDeployTo -n $rgName)
#ToDo: Check that this does not error on duplicate...
echo "Creating AAD Group for SQL Admin"
groupName="paasblueprintsqladminss"
#aadGroupId=$(az ad group create --display-name "PaaS Blueprint SQL Administrators" --mail-nickname "paasblueprintsqladminss" | jq ".objectId" -r)
aadGroupId=$(az ad group create --display-name "PaaS Blueprint SQL Administrators" --mail-nickname "$groupName" | jq ".objectId" -r)

#ToDo: Check that this does not error on duplicate...
#Run the deployment
echo "Starting deployment..."
echo "Assigning logged in user to SQL Administrators Group"

aadUserId=$(az account show | jq ".id" -r)
aadUserMail=$(az account show | jq ".user.name" -r)
addUser=$(az ad group member add -g $aadGroupId --member-id $aadUserId)

paramString="AADAdminLogin=$aadUserId AADAdminObjectID=$aadGroupId AlertSendToEmailAddress=$aadUserMail"

deploymentOutput=$(az group deployment create -g $rgName --template-uri https://raw.githubusercontent.com/ianalderman/ukopaas/master/azuredeploy.json --parameters $paramString)

echo "Deployment completed..."
#ToDo: Check deployment succedded and extract details from output
#Assign current user to the SQL Administrators group (we do this after deployment to give the group a chance to be fully available...)

#Assign the MSI ID to SQL Server
echo "Granting API App permissions in SQL Database..."
#sqlcmd -S <Servername>.database.windows.net -U <username> -P <password> -Q "GRANT " -o SQLOutput.txt
#Grep the SQLOutput for success
echo "Script finished"

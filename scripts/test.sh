#Request user region
#!/bin/bash
if [ $# -eq 0 ]; then
    echo -n "Would you like a list of regions to deploy to? Y/N (N):"
    read listlocations

    if [ $listlocations == "Y" -o $listlocations == "y" ]; then 
        echo "match"
        az account list-locations --query "[].{displayname:displayname, shortname:name}"  --output table
    fi

    echo -n "Please enter the region you wish to deploy to (using the shortname):"
    read regionToDeployTo
fi

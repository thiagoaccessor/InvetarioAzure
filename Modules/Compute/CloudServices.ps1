<#
.Synopsis
Inventory for Azure Cloud Services

.DESCRIPTION
This script consolidates information for all microsoft.compute/cloudservices resource provider in $Resources variable. 
Excel Sheet Name: CloudService

.Link
https://github.com/microsoft/ARI/Modules/Compute/CloudServices.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th May, 2022
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    #$CloudServices0 = $Resources | Where-Object { $_.TYPE -eq 'microsoft.compute/cloudservices' }
    $CloudServices = $Resources | Where-Object { $_.TYPE -eq 'microsoft.classiccompute/domainnames' }

    <######### Insert the resource Process here ########>

    if($CloudServices)
        {
            $tmp = @()
            foreach ($1 in $CloudServices) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.Name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.name;
                            'Location'             = $1.location;
                            'Status'               = $data.status;
                            'Label'                = $data.label;
                            'Hostname'             = $data.hostname;    
                            'Resource U'           = $ResUCount;
                            'Tag Name'             = [string]$Tag.Name;
                            'Tag Value'            = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }                
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.CloudServices) {

        $TableName = ('CloudServicesTable_'+($SmaResources.CloudServices.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')         
        $Exc.Add('Location')             
        $Exc.Add('Status')          
        $Exc.Add('Label')           
        $Exc.Add('Hostname')        
        if($InTag)
        {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value') 
        }

        $ExcelVar = $SmaResources.CloudServices

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'CloudServices' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -Numberformat '0' -Style $Style
    
    }
}
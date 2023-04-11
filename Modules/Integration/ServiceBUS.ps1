﻿<#
.Synopsis
Inventory for Azure ServiceBUS

.DESCRIPTION
This script consolidates information for all microsoft.servicebus/namespaces and  resource provider in $Resources variable. 
Excel Sheet Name: ServiceBUS

.Link
https://github.com/microsoft/ARI/Modules/Infrastructure/ServiceBUS.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{
    <######### Insert the resource extraction here ########>

        $svchub = $Resources | Where-Object {$_.TYPE -eq 'microsoft.servicebus/namespaces'}

    <######### Insert the resource Process here ########>

    if($svchub)
        {
            $tmp = @()

            foreach ($1 in $svchub) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.Name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'SKU'                  = $sku.name;
                            'Status'               = $data.status;
                            'Geo-Replication'      = $data.zoneRedundant;
                            'Throughput Units'     = $1.sku.capacity;
                            'Endpoint'             = $data.serviceBusEndpoint;
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

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.ServiceBUS)
    {
        $TableName = ('ServiceBUSTable_'+($SmaResources.ServiceBUS.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText false -Range I:I
        $condtxt += New-ConditionalText falso -Range I:I

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Status')
        $Exc.Add('Geo-Rep')
        $Exc.Add('Throughput Units')
        $Exc.Add('Endpoint')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.ServiceBUS  

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Service BUS' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
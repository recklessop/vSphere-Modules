
function Push-vLIMessage {
<#	
	.NOTES
	===========================================================================
	Created by: Markus Kraus
	Twitter: @VMarkus_K
	Private Blog: mycloudrevolution.com
	===========================================================================
	Changelog:  
	2016.08 ver 1.0 Base Release 
	===========================================================================
	External Code Sources:  

	===========================================================================
	Tested Against Environment:
	vRealize Log Inisght Version: 3.6
	PowerShell Version: 4.0, 5.0
	OS Version: Windows 8.1, Server 2012 R2
	===========================================================================
	Keywords: VMware, vRealize, Log Insight
	===========================================================================

	.SYNOPSIS
	Push Messages to VMware vRealize Log Inisght.

	.DESCRIPTION
	Push Messages to VMware vRealize Log Inisght.

	.EXAMPLE
	Push-vLIMessage -vLIServer "loginsight.lan.local -vLIAgentID "12862842-5A6D-679C-0E38-0E2BE888BB28" -Text "My Test"

	.EXAMPLE
	Push-vLIMessage -vLIServer "loginsight.lan.local -vLIAgentID "12862842-5A6D-679C-0E38-0E2BE888BB28" -Text "My Test" -Hostname MyTEST -FieldName myTest -FieldContent myTest

	.PARAMETER vLIServer
	Specify the vLI FQDN	

	.PARAMETER vLIAgentID
	Specify the vLI Agent ID

	.PARAMETER Text
	Specify the Event Text

	.PARAMETER Hostname
	Specify the Hostanme displayed in vLI

	.PARAMETER FieldName
	Specify the a Optinal Field Name for vLI

	.PARAMETER FieldContent
	Specify the a Optinal FieldContent for the Field in -FieldName for vLI
	If FielName is missing and FielContent is given, it will be ignored

	.Link
	http://mycloudrevolution.com/
	
#Requires PS -Version 2.0
#>
	[cmdletbinding()]
    param (
    [parameter(Mandatory=$true)]
    [string]$Text,
    [parameter(Mandatory=$true)]
    [string]$vLIServer,
    [parameter(Mandatory=$true)]
    [string]$vLIAgentID,
    [parameter(Mandatory=$false)]
    [string]$Hostname = $env:computername,
    [parameter(Mandatory=$false)]
    [string]$FieldName,
    [parameter(Mandatory=$false)]
    [string]$FieldContent = ""
	)

  $Field_vLI = [ordered]@{
                    name = "PS_vLIMessage"
                    content = "true"
                    }
  $Field_HostName = [ordered]@{
                    name = "hostname"
                    content = $Hostname
                    }
				
  $Fields = @($Field_vLI, $Field_HostName)
	
	if ($FieldName) {
		$Field_Custom = [ordered]@{
                name = $FieldName
                content = $FieldContent
         	    }
		$Fields += @($Field_Custom)
		}
		
    $Restcall = @{
                 messages =    ([Object[]]($Messages = [ordered]@{
                        text = ($Text)
                        fields = ([Object[]]$Fields)
                        }))
                } | convertto-json -Depth 4

    $Resturl = ("http://" + $vLIServer + ":9000/api/v1/messages/ingest/" + $vLIAgentID)
    try
    {
        $Response = Invoke-RestMethod $Resturl -Method Post -Body $Restcall -ContentType 'application/json' -ErrorAction stop
        Write-Host "REST Call to Log Insight server successful"
        Write-Host $Response
    }
    catch
    {
        Write-Host "REST Call failed to Log Insight server"
        Write-Host $error[0]
        Write-Host $Resturl
    }
}
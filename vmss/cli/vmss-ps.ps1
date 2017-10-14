param (
    [string]$rgName,
    [string]$loc = 'koreacentral'
)

New-AzureRmResourceGroup -Name $rgName -Location $loc

New-AzureRmResourceGroupDeployment -Name "vmssdeployment" -ResourceGroupName $rgName `
                                   -TemplateFile .\azuredeploy.json `
                                   -TemplateParameterFile 
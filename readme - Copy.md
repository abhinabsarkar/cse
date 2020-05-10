# Create custom image

## Create a custom VM
Create a VM with [custom extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) with Azure CLI bash script. 

In this sample, a VM will be created with the following installed: 
1. Windows sub-system for linux feature
2. Azure CLI

The first step is to create a resource group & VM
```bash
# Update for admin username & password
AdminUser="******"
AdminPassword="*******"
rgName="rg-win10-custom"
vmName="vm-win10-custom"

# Create a resource group
az group create -g $rgName -l eastus2

# Get the windows10 image
windows10=$(az vm image list --publisher MicrosoftWindowsDesktop --offer Windows-10 --sku 19h2-pro --all --query "[0].urn" -o tsv)

az vm create \
    --resource-group $rgName --name $vmName \
    --image $windows10 --size Standard_D4_v3 --location eastus2 \
    --vnet-name vn-aks-test --subnet sn-aks-test \
    --admin-username $AdminUser --admin-password $AdminPassword \
    --tags Identifier=VM-Win10-Custom \
    --public-ip-address-allocation static \
    --verbose
```

The Custom Script Extension configuration specifies things like script location and the command to be run. You can store this configuration in configuration files, specify it on the command line, or specify it in an Azure Resource Manager template.

In this example, the custom extension will run scripts (powershell) from a file in github.

```bash
# Use Custom Script extension to enable WSL feature
# When creating windows VM, used publisher as "Microsoft.Compute"
# For the Name of the extension - az vm extension image list
# Github file location should point ot the raw file
# 2>&1	These parameters cause this command to first redirect stdout (Standard Output Stream) to the output file, 
#       and then redirects stderr (Standard Error Stream) there as well.
echo "Enable WSL using Custom Script Extension"
az vm extension set \
  --publisher Microsoft.Compute \
  --name CustomScriptExtension \
  --vm-name $vmName \
  --resource-group $rgName \
  --settings '{"commandToExecute": "powershell -ExecutionPolicy Unrestricted -File enable-wsl.ps1 > C:\enable-wsl-logs.txt 2>&1", "fileUris": ["https://raw.githubusercontent.com/abhinabsarkar/cse/master/src/enable-wsl.ps1"]}' \
  --debug

# WSL requires a VM reboot & powershell can't restart it from the next step (Ideall DSC should be used)
# Hence, removing the custom script extension & addng it again
az vm extension delete\
  --name CustomScriptExtension \
  --vm-name $vmName \
  --resource-group $rgName \
  --verbose

# Use Custom Script extension to install softwares on the VM
# When creating windows VM, used publisher as "Microsoft.Compute"
# For the Name of the extension - az vm extension image list
# Github file location should point ot the raw file
# 2>&1	These parameters cause this command to first redirect stdout (Standard Output Stream) to the output file, 
#       and then redirects stderr (Standard Error Stream) there as well.
# Replace username & password value
az vm extension set \
  --publisher Microsoft.Compute \
  --name CustomScriptExtension \
  --vm-name $vmName \
  --resource-group $rgName \
  --protected-settings '{"username":"******", "password":"******"}' \
  --settings '{"commandToExecute": "powershell -ExecutionPolicy Unrestricted -File install-software.ps1 > C:\install-software-logs.txt 2>&1", "fileUris": ["https://raw.githubusercontent.com/abhinabsarkar/cse/master/src/install-software.ps1"]}' \
  --debug
```

## De-provision the VM
De-provisioning generalizes the VM by removing machine-specific information. This generalization makes it possible to deploy many VMs from a single image.
> For windows, [Sysprep](https://technet.microsoft.com/library/bb457073.aspx) removes all the personal account information, among other things, and prepares the machine to be used as an image. Refer this [link for windows](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-custom-images#generalize-the-windows-vm-using-sysprep).  
For linux, the host name is reset to localhost.localdomain. SSH host keys, nameserver configurations, root password, and cached DHCP leases are also deleted. Refer this [link for linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-custom-images#deprovision-the-vm).

## De-allocate and mark the VM as generalized
To create an image, the VM needs to be de-allocated and marked as generalized in Azure.

## Create image
Create an image of the VM.

## Create VMs from the image
Create one or more new VMs from the image. Creating a VM from a custom image is similar to creating a VM using a Marketplace image i.e. you have to provide the information about the image, image provider, offer, SKU, and version.

### References
[Custom Script Extension for Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows)  
[Create a custom image](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-custom-images)   
[Azure Windows VM](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-custom-images)  
[Azure Linux VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-custom-images)
# Create custom image of a Windows VM

## Create a VM & customize using Custom Script Extension
Create a VM & customize it with [custom extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) using Azure CLI bash script. 

In this sample, a windows 10 VM will be created with the following installed: 
1. Windows sub-system for linux feature
2. Softwares installed like Azure CLI, VS Code, Git, Kubectl, Docker Desktop, etc

### Create a VM
The first step is to create a resource group & VM. In this case a windows 10 VM is created.
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
    --admin-username $AdminUser --admin-password $AdminPassword \
    --tags Identifier=VM-Win10-Custom \
    --public-ip-address-allocation static \
    --verbose
```

### Customize the VM using Custom Script Extension
The Custom Script Extension configuration specifies things like script location and the command to be run. You can store this configuration in configuration files, specify it on the command line, or specify it in an Azure Resource Manager template.

In this example, the custom extension will run scripts (powershell) from a file in github.

```bash
# Use Custom Script extension to install softwares & enable WSL feature
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
  --settings '{"commandToExecute": "powershell -ExecutionPolicy Unrestricted -File cse.ps1 > C:\install-software-logs.txt 2>&1", "fileUris": [" https://raw.githubusercontent.com/abhinabsarkar/cse/master/src/cse.ps1"]}' \
  --debug
```
> WSL requires a VM reboot & powershell can't restart it from the next step (Ideally DSC should be used). Hence, enabling the wsl feature at the end and restarting the VM. 

To get the status of this custom script extension, the logs can be found at the location
```cmd
# This location is only for this custom script extension
C:\install-software-logs.txt 
```

### Troubleshooting steps for CustomExtensionScript
Sometimes the extension doesn't run. Remove the extension & then run the above command
```bash
az vm extension delete\
  --name CustomScriptExtension \
  --vm-name $vmName \
  --resource-group $rgName \
  --verbose
```
The logs can be found at the location
```cmd
C:\WindowsAzure\Logs\WaAppAgent.log
``` 
The plugins logs can be found at the location
```cmd
C:\WindowsAzure\Logs\Plugins
```
The plugins downloaded can be found at the location
```
# This is the location where the scripts get downloaded
C:\Packages\Plugins
```

## Create a custom image 
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
[Create a custom Azure Linux VM image](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-custom-images)   
[Create a custom Azure Windows VM image](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-custom-images)  
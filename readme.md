# Create custom image of a Windows VM

## 1. Create a VM & customize using Custom Script Extension
Create a VM & customize it with [custom extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) using Azure CLI bash script. 

In this sample, a windows 10 VM will be created with the following installed: 
1. Windows sub-system for linux feature
2. Softwares installed like Azure CLI, VS Code, Git, Kubectl, Docker Desktop, etc

### Create a VM
The first step is to create a resource group & VM. In this case a windows 10 VM is created.
```bash
# Update the admin username & password
AdminUser="******"
AdminPassword="*******"
rgName="rg-win10-custom"
vmName="vm-win10-custom"
# Create a resource group
az group create -g $rgName -l eastus2
# Get the windows10 image
windows10=$(az vm image list --publisher MicrosoftWindowsDesktop --offer Windows-10 --sku 19h2-pro --all --query "[0].urn" -o tsv)

# Create VM
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

## 2. Create a custom image 
The first step to create a custom image is to generalize the VM. If you have generalized the VM (using [Sysprep for Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource), or [waagent -deprovision for Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/capture-image)) then you should create a generalized image definition using --os-state generalized. If you want to use the VM without removing existing user accounts, create a specialized image definition using --os-state specialized. Refer this [link](https://docs.microsoft.com/en-us/azure/virtual-machines/image-version-vm-cli)

In this example, we are creating a Windows image.
> The steps for a Linux VM will be different

### Generalize the windows VM using Sysprep
Sysprep removes all your personal account and security information, and then prepares the machine to be used as an image.
> After you have run Sysprep on a VM, that VM is considered generalized and cannot be restarted. The process of generalizing a VM is not reversible. If you need to keep the original VM functioning, you should create a [copy of the VM](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/create-vm-specialized#option-3-copy-an-existing-azure-vm) and generalize its copy.

To generalize your Windows VM, follow these steps:
* Sign in to your Windows VM.
* Open a Command Prompt window as an administrator. Change the directory to %windir%\system32\sysprep, and then run sysprep.exe.
* In the System Preparation Tool dialog box, select Enter System Out-of-Box Experience (OOBE) and select the Generalize check box.
* For Shutdown Options, select Shutdown. Select OK.
* When Sysprep completes, it shuts down the VM. **Do not restart the VM.**

![Alt text](/images/sysprep.jpg)

### Create the image
Once the VM is prepared, an image can be created using [Azure portal, powershell](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource#create-a-managed-image-in-the-portal) or cli. The image created will be placed in the same resource group.

The steps to create image using cli are shown below
```bash
# De-allocate the VM 
az vm deallocate -g $rgName -n $vmName --verbose
# Generalize the VM. This action makes the VM unusable
az vm generalize -g $rgName -n $vmName --verbose
# Create image
az image create -g $rgName -n image-win10-custom-20200510 --source $vmName \
  --tags Identifier=Image-Win10-Custom \
  --verbose
# Delete the VM as it becomes unusable
az vm delete -g $rgName -n $vmName --yes --no-wait --verbose
```

## Create VMs from the image
Creating a VM from a custom image is similar to creating a VM using a Marketplace image. In this case, the image is placed in the same resource group. The image can also be placed in [Shared Image Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-image-galleries#generalized-and-specialized-images). A Shared Image Gallery simplifies custom image sharing across your organization. Custom images are like marketplace images, but you create them yourself. Custom images can be used to bootstrap configurations such as preloading applications, application configurations, and other OS configurations.

The steps here are not using the Shared Image Gallery, rather the image stored in the Resource Group.
```bash
az vm create -g $rgName -n VM-Win10-Custom --image image-win10-custom-20200510 \
  --admin-username $AdminUser --admin-password $AdminPassword \
  --public-ip-address-allocation static \
  --tag Identifier=VM-Win10-Custom-Image \
  --verbose
```

## Clean up resources in the resource group
Use the script *delete-custom-vm-n-resources.sh* to delete the resources in the resource group by updating the identifier tag. The script is placed inside the src folder.

## References
[Custom Script Extension for Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows)  
[Tutorial - Create a custom Azure Linux VM image](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-custom-images)   
[Tutorial - Create a custom Azure Windows VM image](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-custom-images)  
[Capture VM to Image - Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource)  
[Capture VM to Image - Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/capture-image)  
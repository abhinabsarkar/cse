# Install ubuntu 18 distro on windows 10 VM
# Download ubuntu 18 distro for wsl
# Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu.appx -UseBasicParsing -Verbose
# Installing ubuntu distro for wsl. Prequisite of the below step is WSL should be enabled
Add-AppxPackage .\Ubuntu.appx

# Install Azure CLI. Since using the Invoke-WebRequest, must specify the parameter -UseBasicParsing else it will fail
# Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; `
#     Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi -Verbose

# Install kubectl 
# Install-Script -Name install-kubectl -Scope CurrentUser -Force -Verbose
# install-kubectl.ps1
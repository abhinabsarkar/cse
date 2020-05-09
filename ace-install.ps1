# Creating folder 'temp' in D: for testing
New-Item -Path 'D:\temp' -ItemType Directory
# Install wsl feature
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -Verbose
# Install Azure CLI. Since using the Invoke-WebRequest, must specify the parameter -UseBasicParsing else it will fail
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi -Verbose
# Install kubectl 
Install-Script -Name install-kubectl -Scope CurrentUser -Force -Verbose
install-kubectl.ps1

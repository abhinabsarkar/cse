# Creating folder 'temp' in D: for testing
New-Item -Path 'c:\abhinab\kubectl' -ItemType Directory
# Install Azure CLI for windows. Since using the Invoke-WebRequest, must specify the parameter -UseBasicParsing else it will fail
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi -Verbose
# Install wsl feature
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -OutVariable results -Verbose
if ($results.RestartNeeded -eq $true) {
  Restart-Computer -Force
}
# Install kubectl for windows

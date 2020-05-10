# Create a directory


# Install ubuntu 18 distro on windows 10 VM
# Download ubuntu 18 distro for wsl
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu.appx -UseBasicParsing -Verbose

# Install Azure CLI. Since using the Invoke-WebRequest, must specify the parameter -UseBasicParsing else it will fail
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi -Verbose

# Install kubectl
$kubectlUrl = "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/windows/amd64/kubectl.exe"
$output = "D:\temp\kubectl.exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($kubectlUrl, $output)

# Install wsl feature
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -Verbose
# Restart the VM if required
if ($results.RestartNeeded -eq $true) {
  Restart-Computer -Force
}
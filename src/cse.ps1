Write-Output "Initiating script"

# Choose a directory path for installing softwares
$softwareDirectory = "C:\abhinab\softwares"
# Create the directory. Use the force switch to create directory even if exists
New-Item -Path $softwareDirectory -ItemType Directory -Force

# Create a web client
$wc = New-Object System.Net.WebClient

# Install kubectl
Write-Output "Download kubectl"
$kubectlWindowsUrl = "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/windows/amd64/kubectl.exe"
$wc.DownloadFile($kubectlWindowsUrl, $softwareDirectory + "\kubectl.exe")
Write-Output "Kubectl downloaded"

# Install git client
Write-Output "Installing git client"
$gitWindowsUrl = "https://github.com/git-for-windows/git/releases/download/v2.26.2.windows.1/Git-2.26.2-64-bit.exe"
$gitDownloadPath = $softwareDirectory + "\Git-2.26.2-64-bit.exe"
$wc.DownloadFile($gitWindowsUrl, $gitDownloadPath)
Start-Process -FilePath $gitDownloadPath -ArgumentList '/VERYSILENT /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"' -Wait -Verbose
# Remove-Item  $gitDownloadPath -Verbose
Write-Output "Git client installation completed"

# # Add kubectl to the environment path
# Write-Output "Adding the kubectl path to the environment variable"
# Clear-Host
# $AddedLocation = $softwareDirectory
# $Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
# $OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path
# $NewPath= $OldPath + ’;’ + $AddedLocation
# Set-ItemProperty -Path "$Reg" -Name PATH –Value $NewPath

# Install vs code
Write-Output "Installing VS Code"
$vscodeWindowsUrl = "https://aka.ms/win32-x64-user-stable"
$vscodeDownloadPath = $softwareDirectory + "\VSCodeUserSetup-x64-1.45.0.exe"
$wc.DownloadFile($vscodeWindowsUrl, $vscodeDownloadPath)
Start-Process -FilePath $vscodeDownloadPath -ArgumentList '/VERYSILENT /MERGETASKS=!runcode' -Wait -Verbose
# Remove-Item  $vscodeDownloadPath -Verbose
Write-Output "VS Code install completed"

# Install Azure CLI. Since using the Invoke-WebRequest, must specify the parameter -UseBasicParsing else it will fail
Write-Output "Install azure cli for windows"
$azureCliWindowsUrl = "https://aka.ms/installazurecliwindows"
$azureCliDownloadPath = $softwareDirectory + "\azure-cli-2.5.1.msi"
$wc.DownloadFile($azureCliWindowsUrl, $azureCliDownloadPath)
$argument = '/I ' + $azureCliDownloadPath + ' /quiet'
Start-Process msiexec.exe -ArgumentList $argument -Wait -Verbose
# Remove-Item $softwareDirectory + ".\AzureCLI.msi" -Verbose
Write-Output "Azure cli install completed"

# Install google chrome
Write-Output "Installing chrome browser"
$chromeUrl = "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$chromeDownloadPath = $softwareDirectory + "\chrome_installer.exe"
$wc.DownloadFile($chromeUrl, $chromeDownloadPath)
Start-Process -FilePath $vscodeDownloadPath -ArgumentList '/silent /install' -Wait -Verbose
# Remove-Item  $chromeDownloadPath -Verbose
Write-Output "Chrome browser install completed"

# Install docker desktop
Write-Output "Installing docker desktop"
$dockerDesktopUrl = "https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
$dockerDesktopDownloadPath = $softwareDirectory + "\Docker Desktop Installer.exe"
$wc.DownloadFile($dockerDesktopUrl, $dockerDesktopDownloadPath)
Start-Process -FilePath $dockerDesktopDownloadPath -ArgumentList 'install --quiet' -Wait -Verbose
Write-Output "Docker desktop install completed"

# Download ubuntu 18 distro for wsl
Write-Output "Download ubuntu distro for wsl"
$wslUbuntuDistroUrl = "https://aka.ms/wsl-ubuntu-1804"
$wc.DownloadFile($wslUbuntuDistroUrl, $softwareDirectory + "\Ubuntu.appx")
Write-Output "Ubuntu distro downloaded"

# Installing the wsl distro is deferred as it will not allow to create a generalized image using sysprep
Write-Output "Install scripts completed"

# Enable wsl feature
Write-Output "Enable wsl feature"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -Verbose
Write-Output "wsl enabled"

# Restart the VM for install like docker & wsl to take affect
Write-Output "Restart the local VM"
Restart-Computer
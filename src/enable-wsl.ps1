# Install wsl feature
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -Verbose
# Restart the VM if required
if ($results.RestartNeeded -eq $true) {
  Restart-Computer -Force
}
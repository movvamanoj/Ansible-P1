# Retrieve the local machine's DNS name
$hostnameOrDNS = [System.Net.Dns]::GetHostByName('').HostName

# Create a self-signed certificate with subject information
$cert = New-SelfSignedCertificate -DnsName $hostnameOrDNS -CertStoreLocation "cert:\LocalMachine\My" -Subject "CN=$hostnameOrDNS"

# Create HTTPS Listener
New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address="*";Transport="HTTPS"} -ValueSet @{Hostname=$hostnameOrDNS; CertificateThumbprint=$cert.Thumbprint}

# Add a firewall rule for WinRM HTTPS
New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow

# Verify WinRM listener configuration
winrm enumerate winrm/config/Listener

# Configure trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Allow Local Account Token Filter Policy
New-ItemProperty -Name LocalAccountTokenFilterPolicy -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -PropertyType DWord -Value 1 -Force

# Set Execution Policy
Set-ExecutionPolicy Unrestricted -Force

# Restart WinRM service
Restart-Service WinRM

# Enable Basic Authentication
Set-Item -Force WSMan:\localhost\Service\auth\Basic $true

# Verify WinRM service configuration
winrm get winrm/config


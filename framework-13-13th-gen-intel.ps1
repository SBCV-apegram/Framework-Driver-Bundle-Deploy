# PowerShell Script for deploying the Driver Bundle for the Framework Laptop 13 (Intel 13th-gen mainboard)
# Speed up download cmdlet
$ProgressPreference = 'SilentlyContinue'

# Download Current Driver Bundle
Invoke-WebRequest https://downloads.frame.work/driver/Framework_Laptop_13th_Gen_Intel_Core_driver_bundle_W11_2023_03_28.exe -OutFile $env:TEMP\frameworkinstall.exe

# Download lightweight 7z extractor
Invoke-WebRequest https://www.7-zip.org/a/7zr.exe -OutFile $env:TEMP\7zr.exe

# Extract bundle contents to temp folder
Set-Location $env:TEMP
New-Item -Path . -Name 'DriverBundle' -ItemType 'directory' -Force
Remove-Item -Path ".\DriverBundle\*" -Recurse
.\7zr.exe x .\frameworkinstall.7z -o".\DriverBundle" -y
Set-Location .\DriverBundle

# Call Framework's batch file in unattended mode
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c', '.\install_drivers.bat', '-u'

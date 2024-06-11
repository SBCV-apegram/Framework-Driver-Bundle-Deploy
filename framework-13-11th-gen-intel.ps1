# PowerShell Script for deploying the Driver Bundle for the Framework Laptop 13 (Intel 11th-gen mainboard)
# Speed up download cmdlet
$ProgressPreference = 'SilentlyContinue'

# Download Current Driver Bundle
Invoke-WebRequest https://downloads.frame.work/driver/Framework_Laptop_driver_bundle_W11_2021_12_15.exe -OutFile $env:TEMP\frameworkinstall.exe

# Download lightweight 7z extractor
Invoke-WebRequest https://www.7-zip.org/a/7zr.exe -OutFile $env:TEMP\7zr.exe

# Extract bundle contents to temp folder
Set-Location $env:TEMP
New-Item -Path . -Name 'DriverBundle' -ItemType 'directory' -Force
Remove-Item -Path ".\DriverBundle\*" -Recurse
.\7zr.exe x .\frameworkinstall.exe -o".\DriverBundle" -y
Set-Location .\DriverBundle

# Download modified install_drivers.bat
Invoke-WebRequest https://github.com/SBCV-apegram/Framework-Driver-Bundle-Deploy/raw/main/11th-gen-install-mod.bat -OutFile .\install_drivers.bat

# Call Framework's batch file in unattended mode
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c', '.\install_drivers.bat', '-u'

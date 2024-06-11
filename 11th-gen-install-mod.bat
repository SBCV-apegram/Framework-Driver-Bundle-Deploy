REM This is a modified version of the batch file included in the 11th gen Intel driver bundle, with the unattended and baseboard checks from later bundles added.

@echo off
NET SESSION >nul 2>&1
if %ERRORLEVEL% EQU 0 (
	echo "Running as admin"
) else (
	echo "Please run as an administrator"
	pause
	exit
)

SET UNATTENDED-0
if "%~1"=="" goto NOPARAM
if "%~1"=="-d" (
	echo "WINDIR = %WINDIR%"
	echo "cwd = "%~dp0"
	set proc
	@echo on
)

if "%~1"=="-u" (
	echo Unattended mode
	SET UNATTENDED=1
)

:NOPARAM

SET DRIVER_FAILURE=0
SET CODEC_DETECTED=0
echo "Framework Starting install: %DATE% %TIME%" >"%TEMP%\frameworkinstall.txt"
wmic bios get serialnumber >> "%TEMP%\frameworkinstall.txt"

REM I do not know all the 11th gen baseboard prefixes, feel free to send a pull request to add more
wmic baseboard get product | findstr "FRANBMCP " 1>nul
if errorlevel 1 (
	echo "This Framework driver bundle is designed to run on 11th Gen Intel Core mainboards only!"
	pause
	exit
)

echo Installing Intel Wifi driver
"%~dp0PHWFW04463_22.80.0.9G\WirelessSetup.exe" -s
CALL :log_result %ERRORLEVEL% "Wifi"

echo Installing Intel SerialIO driver for Touchpad and Hotkey support
"%~dp0SetupSerialIO_30.100.2129.8_PV_TGL_PCH_Win11.exe" -s
CALL :log_result %ERRORLEVEL% "SerialIO"

echo Installing Fingerprint driver
"%~dp0Fingerprint_3.12804.0.140_setup.exe" /q
CALL :log_result %ERRORLEVEL% "Fingerprint"

echo Installing Intel ISH driver
"%~dp0SetupISS__5.4.1.4476v3.exe" -s
CALL :log_result %ERRORLEVEL% "ISH"

echo Installing Intel Dtt driver
"%~dp0Dtt_8.7.10700.22502_Install.exe" -s
CALL :log_result %ERRORLEVEL% "DTT"

echo Installing Intel Gaussian and Neural Accelerator driver
"%WINDIR%\System32\pnputil.exe" -a "%~dp0gna-03.00.00.1363-win10-cobalt-tgl-pv\gna.inf" /install >>"%TEMP%\frameworkinstall.txt" 2>&1
CALL :log_result %ERRORLEVEL% "GNA"

echo Installing Intel Chipset drivers
"%~dp0Chipset-10.1.18793.8276-Public-MUP\SetupChipset.exe" -s -norestart
CALL :log_result %ERRORLEVEL% "Chipset"

echo Installing Intel CSME driver
"%~dp0IntelCSME_TGL-U_15.0.35.1951_V6.2_Corporate\SetupME.exe" -s
CALL :log_result %ERRORLEVEL% "CSME Corp"


echo Installing Intel Bluetooth driver
"%~dp0PHBTW38554_22.80.0.4G\Intel Bluetooth.msi" /passive
CALL :log_result %ERRORLEVEL% "Bluetooth"

echo Installing Intel Graphics driver
echo This may take several minutes
"%~dp0Graphics_Driver_Production_Version_100.9836\installer.exe" -s
CALL :log_result %ERRORLEVEL% "Graphics"


"%WINDIR%\System32\pnputil.exe" /enum-devices /connected | FINDSTR /C:"VEN_10EC&DEV_0295">nul && (
	SET CODEC_DETECTED=1
	echo "Realtek HDA detected" >>"%TEMP%\frameworkinstall.txt"
	echo Installing Intel Smart Sound Driver
	"%WINDIR%\System32\pnputil.exe" -a "%~dp0Intel_SST_TGL_10.29.00.6367\IntcSST.inf" /install >>"%TEMP%\frameworkinstall.txt" 2>&1
	CALL :log_result %ERRORLEVEL% "IntcSST"
	"%WINDIR%\System32\pnputil.exe" -a "%~dp0Intel_SST_TGL_10.29.00.6367\DetectionVerificationDrv.inf" /install >>"%TEMP%\frameworkinstall.txt" 2>&1
	CALL :log_result %ERRORLEVEL% "DetectionVerificationDrv"
	"%WINDIR%\System32\pnputil.exe" -a "%~dp0Intel_SST_TGL_10.29.00.6367\IntcAudioBus.inf" /install >>"%TEMP%\frameworkinstall.txt" 2>&1
	CALL :log_result %ERRORLEVEL% "IntcAudioBus"
	"%WINDIR%\System32\pnputil.exe" -a "%~dp0Intel_SST_TGL_10.29.00.6367\IntcOED.inf" /install >>"%TEMP%\frameworkinstall.txt" 2>&1
	CALL :log_result %ERRORLEVEL% "IntcOED"
	"%WINDIR%\System32\pnputil.exe" -a "%~dp0Intel_SST_TGL_10.29.00.6367\IntcUSB.inf" /install >>"%TEMP%\frameworkinstall.txt" 2>&1
	CALL :log_result %ERRORLEVEL% "IntcUSB"

	echo Installing Realtek driver
	"%~dp0Realtek_6.0.9172.1_WHQL_install\Setup.exe" -s
	CALL :log_result %ERRORLEVEL% "Realtek"
)

"%WINDIR%\System32\pnputil.exe" /enum-devices /connected | FINDSTR /C:"VEN_111D&DEV_7695">nul && (
	SET CODEC_DETECTED=1
	echo "Tempo HDA detected" >>"%TEMP%\frameworkinstall.txt"
	echo Tempo HDA detected

	for /f "tokens=*" %%s in ('powershell "(Get-WmiObject Win32_pnpsigneddriver | where {$_.devicename -like '*(Intel(R) SST) Audio Controller*'}).InfName"') do ( set oem_inf=%%s )
	if defined oem_inf (
	    echo Uninstalling ISST driver... %oem_inf%
	    "%WINDIR%\System32\pnputil.exe" /delete-driver %oem_inf% /uninstall
	)
)

echo Installing Intel Thunderbolt driver
"%~dp0TBT_DCH_SW_Rev84\Thunderbolt(TM) Software Installer.exe" -passive -norestart
CALL :log_result %ERRORLEVEL% "Thunderbolt"

if %CODEC_DETECTED% EQU 0 (
	echo Warning: No Framework Audio Codec detected 
	echo this may happen if you have run this script multiple times without restarting
	echo "No Framework Audio Codec detected" >>"%TEMP%\frameworkinstall.txt"
)

if %DRIVER_FAILURE% EQU 1 (
	echo "ERROR Installing some drivers, please try again"
)
echo Your computer will now restart to complete driver installation
if %UNATTENDED% EQU 0 (
  pause
  shutdown -r -t 10
)

exit /B %ERRORLEVEL%

:log_result
if %~1 EQU 0 (
	echo "%~1 %~2 Install OK" >>"%TEMP%\frameworkinstall.txt"
) else (
	echo "%~1 %~2 Error" >>"%TEMP%\frameworkinstall.txt"
)
EXIT /B 0

@echo off
title Advanced Windows Update Manager
setlocal EnableDelayedExpansion

:: ==========================================
:: 1. Auto-Elevate to Administrator Rights
:: ==========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrative Privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ==========================================
:: 2. Setup ANSI Color Codes
:: ==========================================
for /F "delims=#" %%E in ('prompt #$E# ^& for %%E in ^(1^) do rem') do set "ESC=%%E"
set "GRN=%ESC%[92m"
set "RED=%ESC%[91m"
set "WHT=%ESC%[97m"
set "YLW=%ESC%[93m"
set "RST=%ESC%[0m"

:DASHBOARD
cls
echo %WHT%=======================================================%RST%
echo             %YLW%ADVANCED WINDOWS UPDATE MANAGER%RST%
echo %WHT%=======================================================%RST%

:: ==========================================
:: 3. Read Registry to Detect Current Status
:: ==========================================

:: Check Cumulative/General Updates (NoAutoUpdate)
set "CU_STAT=%GRN%ACTIVE%RST%"
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate 2>nul | find "0x1" >nul
if !errorlevel! equ 0 set "CU_STAT=%RED%DISABLED%RST%"

:: Check Driver Updates (ExcludeWUDriversInQualityUpdate)
set "DRV_STAT=%GRN%ACTIVE%RST%"
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate 2>nul | find "0x1" >nul
if !errorlevel! equ 0 set "DRV_STAT=%RED%DISABLED%RST%"

:: Check Feature Updates / OS Upgrades (DisableOSUpgrade)
set "FEAT_STAT=%GRN%ACTIVE%RST%"
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade 2>nul | find "0x1" >nul
if !errorlevel! equ 0 set "FEAT_STAT=%RED%DISABLED%RST%"

:: Check MS Store Auto Updates (AutoDownload)
set "STR_STAT=%GRN%ACTIVE%RST%"
reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload 2>nul | find "0x2" >nul
if !errorlevel! equ 0 set "STR_STAT=%RED%DISABLED%RST%"

:: ==========================================
:: 4. Display Menu
:: ==========================================
echo.
echo  %WHT%--- INDIVIDUAL CONTROLS ---%RST%
echo  1. Cumulative / General Updates : [%CU_STAT%]
echo  2. Driver Updates               : [%DRV_STAT%]
echo  3. Feature Updates (Upgrades)   : [%FEAT_STAT%]
echo  4. Microsoft Store Auto-Updates : [%STR_STAT%]
echo.
echo  %WHT%--- BULK PRESETS ---%RST%
echo  5. Disable All EXCEPT MS Store
echo  6. Minimum Updates (Security Only, No Drivers/Upgrades)
echo  7. Drivers Only (Disable General, Upgrades, and Store)
echo  8. Restore Windows Defaults (All Active)
echo.
echo  0. Quit
echo %WHT%=======================================================%RST%
set /p "CHOICE=Select an option (0-8): "

if "%CHOICE%"=="1" goto SET_CU
if "%CHOICE%"=="2" goto SET_DRV
if "%CHOICE%"=="3" goto SET_FEAT
if "%CHOICE%"=="4" goto SET_STR
if "%CHOICE%"=="5" goto PRESET_STORE_ONLY
if "%CHOICE%"=="6" goto PRESET_MINIMUM
if "%CHOICE%"=="7" goto PRESET_DRIVERS
if "%CHOICE%"=="8" goto PRESET_DEFAULT
if "%CHOICE%"=="0" exit
goto DASHBOARD

:: ==========================================
:: 5. Individual Toggle Logic
:: ==========================================

:SET_CU
set /p "STATE=Enter 1 (Active) or 0 (Disable): "
if "%STATE%"=="1" reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /f >nul 2>&1
if "%STATE%"=="0" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul 2>&1
goto RESTART_SRV

:SET_DRV
set /p "STATE=Enter 1 (Active) or 0 (Disable): "
if "%STATE%"=="1" reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /f >nul 2>&1
if "%STATE%"=="0" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f >nul 2>&1
goto RESTART_SRV

:SET_FEAT
set /p "STATE=Enter 1 (Active) or 0 (Disable): "
if "%STATE%"=="1" reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /f >nul 2>&1
if "%STATE%"=="0" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /t REG_DWORD /d 1 /f >nul 2>&1
goto RESTART_SRV

:SET_STR
set /p "STATE=Enter 1 (Active) or 0 (Disable): "
if "%STATE%"=="1" reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 4 /f >nul 2>&1
if "%STATE%"=="0" reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 2 /f >nul 2>&1
goto RESTART_SRV

:: ==========================================
:: 6. Bulk Preset Logic
:: ==========================================

:PRESET_STORE_ONLY
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 4 /f >nul 2>&1
goto RESTART_SRV

:PRESET_MINIMUM
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /f >nul 2>&1
goto RESTART_SRV

:PRESET_DRIVERS
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 2 /f >nul 2>&1
goto RESTART_SRV

:PRESET_DEFAULT
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /f >nul 2>&1
goto RESTART_SRV

:: ==========================================
:: 7. Apply and Refresh Services
:: ==========================================
:RESTART_SRV
echo.
echo %YLW%Applying registry changes and restarting Windows Update service...%RST%
net stop wuauserv >nul 2>&1
net start wuauserv >nul 2>&1
timeout /t 2 >nul
goto DASHBOARD

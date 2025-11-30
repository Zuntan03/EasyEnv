@echo off
chcp 65001 > NUL

@REM %USER%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo powershell.exe -Version 5.1 -ExecutionPolicy Bypass -c "if (Test-Path $PROFILE) { exit }; $null = New-Item (Split-Path $PROFILE) -ItemType Directory -Force; Copy-Item '%~dp0profile.ps1' $PROFILE -Force"
powershell.exe -Version 5.1 -ExecutionPolicy Bypass -c ^
"if (Test-Path $PROFILE) { exit }; $null = New-Item (Split-Path $PROFILE) -ItemType Directory -Force; Copy-Item '%~dp0profile.ps1' $PROFILE -Force"
if %ERRORLEVEL% neq 0 ( pause & exit /b 1 )

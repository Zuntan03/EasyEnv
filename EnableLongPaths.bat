@echo off
chcp 65001 > NUL

reg query "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled | find "0x1" > NUL
if %ERRORLEVEL% equ 0 ( exit /b 0 )

echo reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
if %ERRORLEVEL% neq 0 (
	echo "EasyEnv/EnableLongPaths.bat を右クリックして、「管理者として実行」して再起動します。"
	echo "Right-click EasyEnv/EnableLongPaths.bat and select 'Run as administrator', then restart."
	pause & exit /b 1
)

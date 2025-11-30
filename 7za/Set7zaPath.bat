@echo off
chcp 65001 > NUL
setlocal
set "CURL_CMD=C:\Windows\System32\curl.exe -fkL"
set "PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass"

@REM https://www.7-zip.org/
set "SZA_VERSION=25.01"

if not "%~1"=="" echo %~1> "%~dp07zaVersion.txt"
if exist "%~dp07zaVersion.txt" (
	set /p SZA_VERSION=<"%~dp07zaVersion.txt"
) else (
	echo %SZA_VERSION%> "%~dp07zaVersion.txt"
)
if exist "%~dp0%SZA_VERSION%\7za.exe" goto :7ZA_INSTALLED

set "SZR_EXE_NAME=7zr.exe"
set "SZR_EXE_URL=https://www.7-zip.org/a/%SZR_EXE_NAME%"
set "SZR_EXE_PATH=%~dp0%SZA_VERSION%\%SZR_EXE_NAME%"

if exist "%SZR_EXE_PATH%" goto :7ZR_INSTALLED

if not exist "%~dp0%SZA_VERSION%\" mkdir "%~dp0%SZA_VERSION%\"

echo %CURL_CMD% -o "%SZR_EXE_PATH%" "%SZR_EXE_URL%"
%CURL_CMD% -o "%SZR_EXE_PATH%" "%SZR_EXE_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download 7zr. "%SZR_EXE_URL%" "%SZR_EXE_PATH%"
	pause & endlocal & exit /b 1
)

:7ZR_INSTALLED

set "SZA_ZIP_VERSION=%SZA_VERSION:.=%"
set "SZA_ZIP_NAME=7z%SZA_ZIP_VERSION%-extra.7z"
set "SZA_ZIP_URL=https://www.7-zip.org/a/%SZA_ZIP_NAME%"
set "SZA_ZIP_PATH=%~dp0%SZA_ZIP_NAME%"

echo %CURL_CMD% -o "%SZA_ZIP_PATH%" "%SZA_ZIP_URL%"
%CURL_CMD% -o "%SZA_ZIP_PATH%" "%SZA_ZIP_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download 7za. "%SZA_ZIP_URL%" "%SZA_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo %SZR_EXE_PATH% x -o"%~dp0%SZA_VERSION%\" "%SZA_ZIP_PATH%" -y
%SZR_EXE_PATH% x -o"%~dp0%SZA_VERSION%\" "%SZA_ZIP_PATH%" -y
if %ERRORLEVEL% neq 0 (
	echo Failed to extract 7za. "%SZA_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo del /f /q "%SZA_ZIP_PATH%"
del /f /q "%SZA_ZIP_PATH%"

:7ZA_INSTALLED

echo "%PATH%" | find /i "%~dp0%SZA_VERSION%" >NUL
if %ERRORLEVEL% neq 0 (
	cd>NUL 2>&1
	echo set "PATH=%~dp0%SZA_VERSION%;%%PATH%%"
	goto :SET_7ZA_PATH
)
endlocal
exit /b 0

:SET_7ZA_PATH
(
	endlocal
	set "PATH=%~dp0%SZA_VERSION%;%PATH%"
)

@echo off
chcp 65001 > NUL

@REM 互換性重視
if "%UV_LINK_MODE%" equ "" ( set "UV_LINK_MODE=copy" )

@REM uv cache dir
if "%UV_CACHE_DIR%" equ "" ( set "UV_CACHE_DIR=%~dp0Cache" )

@REM uv python dir
if "%UV_PYTHON_INSTALL_DIR%" equ "" ( set "UV_PYTHON_INSTALL_DIR=%~dp0Python" )

echo.
echo UV_LINK_MODE: %UV_LINK_MODE%
echo UV_CACHE_DIR: %UV_CACHE_DIR%
echo UV_PYTHON_INSTALL_DIR: %UV_PYTHON_INSTALL_DIR%

echo doskey uv=uv.exe --project "%CD%" $*
doskey uv=uv.exe --project "%CD%" $*
if %ERRORLEVEL% neq 0 ( pause & exit /b 1 )

setlocal
set "CURL_CMD=C:\Windows\System32\curl.exe -fkL"
set "PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass"

@REM https://github.com/astral-sh/uv/releases
set "UV_VERSION=0.9.13"

if "%~1" neq "" (
	echo %~1> "%~dp0UvVersion.txt"
)
if exist "%~dp0UvVersion.txt" (
	set /p UV_VERSION=<"%~dp0UvVersion.txt"
) else (
	echo %UV_VERSION%> "%~dp0UvVersion.txt"
)
if exist "%~dp0%UV_VERSION%\uv.exe" ( goto :UV_INSTALLED )

set "UV_ZIP_NAME=uv-x86_64-pc-windows-msvc.zip"
set "UV_ZIP_URL=https://github.com/astral-sh/uv/releases/download/%UV_VERSION%/%UV_ZIP_NAME%"
set "UV_ZIP_PATH=%~dp0%UV_ZIP_NAME%"

echo %CURL_CMD% -o "%UV_ZIP_PATH%" "%UV_ZIP_URL%"
%CURL_CMD% -o "%UV_ZIP_PATH%" "%UV_ZIP_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download UV. "%UV_ZIP_URL%" "%UV_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo %PS_CMD% -c "Expand-Archive -Path '%UV_ZIP_PATH%' -DestinationPath '%~dp0%UV_VERSION%\' -Force"
%PS_CMD% -c "Expand-Archive -Path '%UV_ZIP_PATH%' -DestinationPath '%~dp0%UV_VERSION%\' -Force"
if %ERRORLEVEL% neq 0 (
	echo Failed to extract UV. "%UV_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo del /f /q "%UV_ZIP_PATH%"
del /f /q "%UV_ZIP_PATH%"

:UV_INSTALLED

echo "%PATH%" | find /i "%~dp0%UV_VERSION%" >NUL
if %ERRORLEVEL% neq 0 (
	cd>NUL 2>&1
	echo set "PATH=%~dp0%UV_VERSION%;%%PATH%%"
	goto :SET_UV_PATH
)
endlocal
exit /b 0

:SET_UV_PATH
(
	endlocal
	set "PATH=%~dp0%UV_VERSION%;%PATH%"
)

@echo off
chcp 65001 > NUL

pushd "%~dp0"

@REM ---------- Sync start SetGitPath.bat, Installer.bat ----------
setlocal

if "%EASY_GIT_USE_PORTABLE%" neq "" (  goto :USE_PORTABLE_GIT )
where /Q git
if %ERRORLEVEL% equ 0 ( endlocal & goto :GIT_EXISTS )
cd>NUL 2>&1
:USE_PORTABLE_GIT

set "CURL_CMD=C:\Windows\System32\curl.exe -fkL"

@REM https://github.com/git-for-windows/git/releases
if "%GIT_VERSION%" equ "" ( set "GIT_VERSION=2.52.0" )

if "%~1" neq "" (
	echo %~1> "%CD%\GitVersion.txt"
)
if exist "%CD%\GitVersion.txt" (
	set /p GIT_VERSION=<"%CD%\GitVersion.txt"
) else (
	echo %GIT_VERSION%> "%CD%\GitVersion.txt"
)
if exist "%CD%\%GIT_VERSION%\bin\git.exe" goto :GIT_INSTALLED

set "GIT_ZIP_NAME=PortableGit-%GIT_VERSION%-64-bit.7z.exe"
set "GIT_ZIP_URL=https://github.com/git-for-windows/git/releases/download/v%GIT_VERSION%.windows.1/%GIT_ZIP_NAME%"
set "GIT_ZIP_PATH=%CD%\%GIT_ZIP_NAME%"

echo %CURL_CMD% -o "%GIT_ZIP_PATH%" "%GIT_ZIP_URL%"
%CURL_CMD% -o "%GIT_ZIP_PATH%" "%GIT_ZIP_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download GIT. "%GIT_ZIP_URL%" "%GIT_ZIP_PATH%"
	pause & endlocal & popd & exit /b 1
)

set "SZR_EXE_NAME=7zr.exe"
set "SZR_EXE_URL=https://www.7-zip.org/a/%SZR_EXE_NAME%"
set "SZR_EXE_PATH=%CD%\7zr\%SZR_EXE_NAME%"

if exist "%SZR_EXE_PATH%" ( goto :7ZR_INSTALLED )

if not exist "%CD%\7zr\" ( mkdir "%CD%\7zr\" )

echo %CURL_CMD% -o "%SZR_EXE_PATH%" "%SZR_EXE_URL%"
%CURL_CMD% -o "%SZR_EXE_PATH%" "%SZR_EXE_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download 7zr. "%SZR_EXE_URL%" "%SZR_EXE_PATH%"
	pause & endlocal & popd & exit /b 1
)

:7ZR_INSTALLED

echo %SZR_EXE_PATH% x -o"%CD%\%GIT_VERSION%\" "%GIT_ZIP_PATH%" -y
%SZR_EXE_PATH% x -o"%CD%\%GIT_VERSION%\" "%GIT_ZIP_PATH%" -y
if %ERRORLEVEL% neq 0 (
	echo Failed to extract Git. "%GIT_ZIP_PATH%"
	pause & endlocal & popd & exit /b 1
)

echo del /f /q "%GIT_ZIP_PATH%"
del /f /q "%GIT_ZIP_PATH%"

echo start /b "" "%CD%\%GIT_VERSION%\post-install.bat"
start /b "" "%CD%\%GIT_VERSION%\post-install.bat"

:GIT_INSTALLED

echo "%PATH%" | find /i "%CD%\%GIT_VERSION%\bin" >NUL
if %ERRORLEVEL% equ 0 ( endlocal & goto :GIT_EXISTS )

cd>NUL 2>&1
echo set "PATH=%CD%\%GIT_VERSION%\bin;%%PATH%%"
(
	endlocal
	set "PATH=%CD%\%GIT_VERSION%\bin;%PATH%"
)

:GIT_EXISTS
popd

@REM ---------- Sync end SetGitPath.bat, Installer.bat ----------

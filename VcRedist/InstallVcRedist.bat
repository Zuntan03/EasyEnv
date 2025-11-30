@echo off
chcp 65001 > NUL

if exist "%~dp0vc_redist.x64.exe" ( exit /b 0 )

@REM Debug
if exist "%~dp0vc_redist.x64.exe" ( goto :EXIST_VC_REDIST )
setlocal
set CURL_CMD=C:\Windows\System32\curl.exe -fkL
echo %CURL_CMD% -o "%~dp0vc_redist.x64.exe" https://aka.ms/vs/17/release/vc_redist.x64.exe
%CURL_CMD% -o "%~dp0vc_redist.x64.exe" https://aka.ms/vs/17/release/vc_redist.x64.exe
if %ERRORLEVEL% neq 0 pause & endlocal & exit /b 1
endlocal

:EXIST_VC_REDIST
start "" "%~dp0vc_redist.x64.exe" /install /passive /norestart

@echo off
chcp 65001 > NUL

if "%LLAMACPP_LINK_MODE%" equ "" (
	echo if "%%LLAMACPP_LINK_MODE%%" equ "" ^( set "LLAMACPP_LINK_MODE=copy" ^)
	set "LLAMACPP_LINK_MODE=copy"
)

setlocal
set "PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass"

@REM https://github.com/ggml-org/llama.cpp/releases
set "LLAMACPP_VERSION=b7077"
set "LLAMACPP_MIRRORED_VERSIONS=b7077"

if "%~1" neq "" (
	echo %~1> "%~dp0LlamacppVersion.txt"
)
if exist "%~dp0LlamacppVersion.txt" (
	set /p LLAMACPP_VERSION=<"%~dp0LlamacppVersion.txt"
) else (
	echo %LLAMACPP_VERSION%> "%~dp0LlamacppVersion.txt"
)
if exist "%~dp0%LLAMACPP_VERSION%\llama-server.exe" ( goto :LLAMACPP_INSTALLED )

set "LLAMACPP_VERSION_MIRRORED=0"
for %%V in (%LLAMACPP_MIRRORED_VERSIONS%) do (
	if "%%V"=="%LLAMACPP_VERSION%" (
		set "LLAMACPP_VERSION_MIRRORED=1"
	)
)

set "CUDART_ZIP_NAME=cudart-llama-bin-win-cuda-12.4-x64.zip"
@REM set "CUDART_ZIP_URL=https://github.com/ggml-org/llama.cpp/releases/download/%LLAMACPP_VERSION%/%CUDART_ZIP_NAME%"
set "CUDART_ZIP_URL=https://huggingface.co/Zuntan/llama.cpp.zip/resolve/main/%CUDART_ZIP_NAME%"
set "CUDART_ZIP_PATH=%~dp0%CUDART_ZIP_NAME%"

call "%~dp0..\Aria2\Aria2Download.bat" "%~dp0" "%CUDART_ZIP_NAME%" "%CUDART_ZIP_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download CUDART. "%CUDART_ZIP_URL%" "%CUDART_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo %PS_CMD% -c "Expand-Archive -Path '%CUDART_ZIP_PATH%' -DestinationPath '%~dp0%LLAMACPP_VERSION%\' -Force"
%PS_CMD% -c "Expand-Archive -Path '%CUDART_ZIP_PATH%' -DestinationPath '%~dp0%LLAMACPP_VERSION%\' -Force"
if %ERRORLEVEL% neq 0 (
	echo Failed to extract CUDART. "%CUDART_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo del /f /q "%CUDART_ZIP_PATH%"
del /f /q "%CUDART_ZIP_PATH%"

set "LLAMACPP_ZIP_NAME=llama-%LLAMACPP_VERSION%-bin-win-cuda-12.4-x64.zip"
set "LLAMACPP_ZIP_URL=https://github.com/ggml-org/llama.cpp/releases/download/%LLAMACPP_VERSION%/%LLAMACPP_ZIP_NAME%"
set "LLAMACPP_ZIP_PATH=%~dp0%LLAMACPP_ZIP_NAME%"

if "%LLAMACPP_VERSION_MIRRORED%"=="0" ( goto :LLAMACPP_VERSION_NOT_MIRRORED )
set "LLAMACPP_ZIP_URL=https://huggingface.co/Zuntan/llama.cpp.zip/resolve/main/%LLAMACPP_ZIP_NAME%"
:LLAMACPP_VERSION_NOT_MIRRORED

call "%~dp0..\Aria2\Aria2Download.bat" "%~dp0" "%LLAMACPP_ZIP_NAME%" "%LLAMACPP_ZIP_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download Llama.cpp. "%LLAMACPP_ZIP_URL%" "%LLAMACPP_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo %PS_CMD% -c "Expand-Archive -Path '%LLAMACPP_ZIP_PATH%' -DestinationPath '%~dp0%LLAMACPP_VERSION%\' -Force"
%PS_CMD% -c "Expand-Archive -Path '%LLAMACPP_ZIP_PATH%' -DestinationPath '%~dp0%LLAMACPP_VERSION%\' -Force"
if %ERRORLEVEL% neq 0 (
	echo Failed to extract Llama.cpp. "%LLAMACPP_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo del /f /q "%LLAMACPP_ZIP_PATH%"
del /f /q "%LLAMACPP_ZIP_PATH%"

:LLAMACPP_INSTALLED

echo "%PATH%" | find /i "%~dp0%LLAMACPP_VERSION%" >NUL
if %ERRORLEVEL% neq 0 (
	cd>NUL 2>&1
	echo set "PATH=%~dp0%LLAMACPP_VERSION%;%%PATH%%"
	goto :SET_LLAMACPP_PATH
)
endlocal
exit /b 0

:SET_LLAMACPP_PATH
(
	endlocal
	set "PATH=%~dp0%LLAMACPP_VERSION%;%PATH%"
)

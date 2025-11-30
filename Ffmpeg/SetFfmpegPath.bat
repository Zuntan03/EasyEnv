@echo off
chcp 65001 > NUL
setlocal
set "PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass"

@REM https://github.com/GyanD/codexffmpeg/releases/
set "FFMPEG_VERSION=8.0.1"

if not "%~1"=="" (
	echo %~1> "%~dp0FfmpegVersion.txt"
)
if exist "%~dp0FfmpegVersion.txt" (
	set /p FFMPEG_VERSION=<"%~dp0FfmpegVersion.txt"
) else (
	echo %FFMPEG_VERSION%> "%~dp0FfmpegVersion.txt"
)
if exist "%~dp0%FFMPEG_VERSION%\bin\ffmpeg.exe" ( goto :FFMPEG_INSTALLED )

set "FFMPEG_BUILD_NAME=ffmpeg-%FFMPEG_VERSION%-full_build-shared"
set "FFMPEG_ZIP_NAME=%FFMPEG_BUILD_NAME%.7z"
set "FFMPEG_ZIP_URL=https://github.com/GyanD/codexffmpeg/releases/download/%FFMPEG_VERSION%/%FFMPEG_ZIP_NAME%"
set "FFMPEG_ZIP_PATH=%~dp0%FFMPEG_ZIP_NAME%"

call "%~dp0..\Aria2\Aria2Download.bat" "%~dp0" "%FFMPEG_ZIP_NAME%" "%FFMPEG_ZIP_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download FFmpeg. "%FFMPEG_ZIP_URL%" "%FFMPEG_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

call "%~dp0..\7za\Set7zaPath.bat"
if %ERRORLEVEL% neq 0 (
	echo Failed to setup 7za dependency for FFmpeg.
	pause & endlocal & exit /b 1
)

echo 7za.exe x -o"%~dp0" "%FFMPEG_ZIP_PATH%" -y
7za.exe x -o"%~dp0" "%FFMPEG_ZIP_PATH%" -y
if %ERRORLEVEL% neq 0 (
	echo Failed to extract FFmpeg. "%FFMPEG_ZIP_PATH%"
	pause & endlocal & exit /b 1
)

echo ren "%~dp0%FFMPEG_BUILD_NAME%" "%FFMPEG_VERSION%"
ren "%~dp0%FFMPEG_BUILD_NAME%" "%FFMPEG_VERSION%"
if %ERRORLEVEL% neq 0 (
	echo Failed to rename FFmpeg directory.
	pause & endlocal & exit /b 1
)

echo del /f /q "%FFMPEG_ZIP_PATH%"
del /f /q "%FFMPEG_ZIP_PATH%"

:FFMPEG_INSTALLED
echo "%PATH%" | find /i "%~dp0%FFMPEG_VERSION%\bin" >NUL
if %ERRORLEVEL% neq 0 (
	cd>NUL 2>&1
	echo set "PATH=%~dp0%FFMPEG_VERSION%\bin;%%PATH%%"
	goto :SET_FFMPEG_PATH
)
endlocal
exit /b 0

:SET_FFMPEG_PATH
(
	endlocal
	set "PATH=%~dp0%FFMPEG_VERSION%\bin;%PATH%"
)

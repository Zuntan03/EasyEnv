@echo off
chcp 65001 > NUL

@REM No arguments.
call "%~dp0SetFfmpegPath.bat"
if %ERRORLEVEL% neq 0 ( exit /b 1 )

setlocal
set /p FFMPEG_VERSION=<"%~dp0FfmpegVersion.txt"

set "DST_DIR=."
if "%~1" neq "" (
	set "DST_DIR=%~1"
)
if exist "%DST_DIR%\ffmpeg.exe" ( endlocal & exit /b 0 )

@REM os.add_dll_directory(r".venv\Lib\site-packages\torchcodec")
echo xcopy /EIQY "%~dp0%FFMPEG_VERSION%\bin\" "%DST_DIR%\"
xcopy /EIQY "%~dp0%FFMPEG_VERSION%\bin\" "%DST_DIR%\"
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )

endlocal

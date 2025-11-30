@echo off
chcp 65001 > NUL
setlocal

set "DOWNLOAD_DIR=%~1"
set "DOWNLOAD_FILE=%~2"
set "REPO_ID=%~3"
set "REPO_DIR=%~4"

@REM 引数チェック
if "%DOWNLOAD_DIR%"=="" ( echo Error: DOWNLOAD_DIR is required. & endlocal & exit /b 1 )
if "%DOWNLOAD_FILE%"=="" ( echo Error: DOWNLOAD_FILE is required. & endlocal & exit /b 1 )
if "%REPO_ID%"=="" ( echo Error: REPO_ID is required. & endlocal & exit /b 1 )

set "HF_MODEL_CARD=https://huggingface.co/%REPO_ID%"
set "HF_DOWNLOAD_URL=%HF_MODEL_CARD%/resolve/main/%REPO_DIR%%DOWNLOAD_FILE%"

echo.
echo %HF_MODEL_CARD% %REPO_DIR%%DOWNLOAD_FILE%

call "%~dp0Aria2Download.bat" "%DOWNLOAD_DIR%" "%DOWNLOAD_FILE%" "%HF_DOWNLOAD_URL%"
if %ERRORLEVEL% neq 0 ( endlocal & exit /b 1 )

endlocal & exit /b 0

@echo off
chcp 65001 > NUL
setlocal
set "PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass"

set "LINK_DST=%~1"
set "LINK_DST_DIR=%~dp1"
set "LINK_DST_NAME=%~nx1"
set "LINK_SRC=%~2"

@REM 引数チェック
if "%LINK_DST%"=="" ( echo Error: LINK_DST is required. & endlocal & exit /b 1 )
if "%LINK_SRC%"=="" ( echo Error: LINK_SRC is required. & endlocal & exit /b 1 )

@REM LINK_DST が既にジャンクションなら何もしない
for /f "delims=" %%i in ('dir /aL /b "%LINK_DST_DIR%" 2^>NUL') do (
	if /i "%%~i"=="%LINK_DST_NAME%" ( endlocal & exit /b 0 )
)

echo.

@REM 既存ディレクトリがあればタイムスタンプ付きでリネーム
for /f %%i in ('%PS_CMD% -c "Get-Date -Format yyyyMMdd_HHmm_ssff"') do (
	set "NEW_NAME=%LINK_DST_NAME%-%%i"
)

if exist "%LINK_DST%" (
	setlocal enabledelayedexpansion
	echo ren "%LINK_DST%" "!NEW_NAME!"
	ren "%LINK_DST%" "!NEW_NAME!"
	if !ERRORLEVEL! neq 0 ( pause & endlocal & endlocal & exit /b 1 )
	endlocal
)

@REM ジャンクション作成
echo mklink /j "%LINK_DST%" "%LINK_SRC%"
mklink /j "%LINK_DST%" "%LINK_SRC%"
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )

endlocal

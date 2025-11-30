@echo off
chcp 65001 > NUL
setlocal
set "CURL_CMD=C:\Windows\System32\curl.exe -fkL"
set "PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass"

set "DOWNLOAD_DIR=%~1"
set "DOWNLOAD_FILE=%~2"
set "DOWNLOAD_URL=%~3"

@REM 引数チェック
if "%DOWNLOAD_DIR%"=="" ( echo Error: DOWNLOAD_DIR is required. & endlocal & exit /b 1 )
if "%DOWNLOAD_FILE%"=="" ( echo Error: DOWNLOAD_FILE is required. & endlocal & exit /b 1 )
if "%DOWNLOAD_URL%"=="" ( echo Error: DOWNLOAD_URL is required. & endlocal & exit /b 1 )

@REM 既存ファイルチェック
if exist "%DOWNLOAD_DIR%%DOWNLOAD_FILE%" (
	if exist "%~dp0Aria2UseCurl.txt" ( endlocal & exit /b 0 )
	if not exist "%DOWNLOAD_DIR%%DOWNLOAD_FILE%.aria2" ( endlocal & exit /b 0 )
)

@REM ディレクトリ作成
if not exist "%DOWNLOAD_DIR%" ( mkdir "%DOWNLOAD_DIR%" )

@REM Curl モード
if exist "%~dp0Aria2UseCurl.txt" ( goto :DOWNLOAD_WITH_CURL )

@REM Aria2 バージョン管理
set "ARIA2_VERSION=1.37.0"
if exist "%~dp0Aria2Version.txt" (
	set /p ARIA2_VERSION=<"%~dp0Aria2Version.txt"
) else (
	echo %ARIA2_VERSION%> "%~dp0Aria2Version.txt"
)

@REM 接続数設定
set "ARIA2_MAX_CONNECTION=4"
if exist "%~dp0Aria2MaxConnection.txt" (
	set /p ARIA2_MAX_CONNECTION=<"%~dp0Aria2MaxConnection.txt"
) else (
	echo %ARIA2_MAX_CONNECTION%> "%~dp0Aria2MaxConnection.txt"
)

set "ARIA2_NAME=aria2-%ARIA2_VERSION%-win-64bit-build1"
set "ARIA2_EXE=%~dp0%ARIA2_VERSION%\%ARIA2_NAME%\aria2c.exe"
set "ARIA2_CMD=%ARIA2_EXE% --console-log-level=warn --file-allocation=none --check-certificate=false --disable-ipv6 -x%ARIA2_MAX_CONNECTION%"

@REM Aria2 未インストール時はダウンロード
if not exist "%ARIA2_EXE%" (
	if not exist "%~dp0%ARIA2_VERSION%\" ( mkdir "%~dp0%ARIA2_VERSION%\" )

	set "ARIA2_ZIP_NAME=%ARIA2_NAME%.zip"
	set "ARIA2_ZIP_URL=https://github.com/aria2/aria2/releases/download/release-%ARIA2_VERSION%/%ARIA2_NAME%.zip"
	set "ARIA2_ZIP_PATH=%~dp0%ARIA2_VERSION%\%ARIA2_NAME%.zip"

	setlocal enabledelayedexpansion
	echo %CURL_CMD% -o "!ARIA2_ZIP_PATH!" "!ARIA2_ZIP_URL!"
	%CURL_CMD% -o "!ARIA2_ZIP_PATH!" "!ARIA2_ZIP_URL!"
	if !ERRORLEVEL! neq 0 (
		echo Failed to download Aria2. "!ARIA2_ZIP_URL!"
		endlocal & endlocal & exit /b 1
	)

	echo %PS_CMD% -c "Expand-Archive -Path '!ARIA2_ZIP_PATH!' -DestinationPath '%~dp0%ARIA2_VERSION%\' -Force"
	%PS_CMD% -c "Expand-Archive -Path '!ARIA2_ZIP_PATH!' -DestinationPath '%~dp0%ARIA2_VERSION%\' -Force"
	if !ERRORLEVEL! neq 0 (
		echo Failed to extract Aria2. "!ARIA2_ZIP_PATH!"
		endlocal & endlocal & exit /b 1
	)

	echo del /f /q "!ARIA2_ZIP_PATH!"
	del /f /q "!ARIA2_ZIP_PATH!"
	endlocal
)

@REM aria2c が DOWNLOAD_DIR 末尾の \" を正しくエスケープできない問題への対処
if "%DOWNLOAD_DIR:~-1%"=="\" ( set "DOWNLOAD_DIR=%DOWNLOAD_DIR:~0,-1%" )

@REM Aria2 でダウンロード
echo.
echo %ARIA2_CMD% -d "%DOWNLOAD_DIR%" -o "%DOWNLOAD_FILE%" "%DOWNLOAD_URL%"
%ARIA2_CMD% -d "%DOWNLOAD_DIR%" -o "%DOWNLOAD_FILE%" "%DOWNLOAD_URL%"
if %ERRORLEVEL% neq 0 (
	echo Aria2 download failed. Falling back to Curl...
	@REM .aria2 ファイル削除
	if exist "%DOWNLOAD_DIR%\%DOWNLOAD_FILE%.aria2" (
		del /f /q "%DOWNLOAD_DIR%\%DOWNLOAD_FILE%.aria2"
	)
	goto :DOWNLOAD_WITH_CURL
)

endlocal & exit /b 0

:DOWNLOAD_WITH_CURL
echo.
echo %CURL_CMD% -o "%DOWNLOAD_DIR%%DOWNLOAD_FILE%" "%DOWNLOAD_URL%"
%CURL_CMD% -o "%DOWNLOAD_DIR%%DOWNLOAD_FILE%" "%DOWNLOAD_URL%"
if %ERRORLEVEL% neq 0 (
	echo Failed to download with Curl. "%DOWNLOAD_URL%"
	endlocal & exit /b 1
)
endlocal & exit /b 0

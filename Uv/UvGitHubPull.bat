@echo off
chcp 65001 > NUL

@REM 引数:
@REM %1=GITHUB_USER
@REM %2=GITHUB_REPOSITORY
@REM %3=GITHUB_MASTER_BRANCH
@REM %4=VERSION タグかハッシュ。ハッシュのブランチ名は YYYYMMDD_先頭7文字 
@REM %5=REQUIREMENTS_PATH (省略可、DISABLE_UV_ADD で uv add を無効化)

@REM 環境変数 EASY_UV_LOCK_UPDATE_PROJECT 設定時は uv add も実行

setlocal
set "PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass"
set "GITHUB_USER=%~1"
set "GITHUB_REPOSITORY=%~2"
set "GITHUB_MASTER_BRANCH=%~3"
set "VERSION=%~4"
set "REQUIREMENTS_PATH=%~5"
if "%REQUIREMENTS_PATH%"=="" ( set "REQUIREMENTS_PATH=requirements.txt" )

@REM リポジトリをクローン/プル（GitPull.bat を直接呼ぶ）
call "%~dp0..\Git\GitPull.bat" "https://github.com/%GITHUB_USER%/%GITHUB_REPOSITORY%" "%GITHUB_MASTER_BRANCH%"
if %ERRORLEVEL% neq 0 ( endlocal & exit /b 1 )

if "%VERSION%"=="" ( goto :UV_ADD )

@REM タグかハッシュかを判定してブランチ名を決定
set "TAG_EXISTS="
for /f %%t in ('git -C "%GITHUB_REPOSITORY%" tag -l "%VERSION%"') do set "TAG_EXISTS=%%t"
if "%TAG_EXISTS%"=="%VERSION%" (
	set "BRANCH_NAME=tag/%VERSION%"
) else (
	call set "BRANCH_NAME=hash/%VERSION:~0,7%"
)

echo git -C %GITHUB_REPOSITORY% switch -C %BRANCH_NAME% %VERSION%
git -C %GITHUB_REPOSITORY% switch -C %BRANCH_NAME% %VERSION%
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )

:UV_ADD
@REM switch 後に uv add
if "%EASY_UV_LOCK_UPDATE_PROJECT%"=="" ( goto :SKIP_UV_LOCK_UPDATE )
if not exist "%GITHUB_REPOSITORY%\%REQUIREMENTS_PATH%" ( goto :SKIP_UV_LOCK_UPDATE )
if "%REQUIREMENTS_PATH%"=="DISABLE_UV_ADD" ( goto :SKIP_UV_LOCK_UPDATE )
echo uv add --project "%EASY_UV_LOCK_UPDATE_PROJECT%" -r "%GITHUB_REPOSITORY%\%REQUIREMENTS_PATH%"
uv add --project "%EASY_UV_LOCK_UPDATE_PROJECT%" -r "%GITHUB_REPOSITORY%\%REQUIREMENTS_PATH%"
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )
:SKIP_UV_LOCK_UPDATE

endlocal

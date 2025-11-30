@echo off
chcp 65001 > NUL

call "%~dp0SetGitPath.bat"
if %ERRORLEVEL% neq 0 ( exit /b 1 )

setlocal
set "GIT_PULL_URL=%~1"
set "GIT_PULL_MASTER_BRANCH=%2"

echo %GIT_PULL_URL%
for /f "tokens=*" %%i in ("%GIT_PULL_URL%") do (
	set "GIT_PULL_DIR=%%~nxi"
)

if not exist "%GIT_PULL_DIR%\" ( goto :GIT_PULL_DIR_NOT_EXIST )

for /f "delims=" %%i in ('git -C %GIT_PULL_DIR% config --get remote.origin.url') do (
	set "REMOTE_ORIGIN_URL=%%i"
)

if "%GIT_PULL_URL%" neq "%REMOTE_ORIGIN_URL%" ( goto :DIFFERENT_REMOTE_URL )

if "%GIT_PULL_MASTER_BRANCH%" neq "" (
	echo git -C "%GIT_PULL_DIR%" switch -f %GIT_PULL_MASTER_BRANCH% --quiet
	git -C "%GIT_PULL_DIR%" switch -f %GIT_PULL_MASTER_BRANCH% --quiet
)

echo git -C "%GIT_PULL_DIR%" pull
git -C "%GIT_PULL_DIR%" pull
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )
endlocal
exit /b 0

:DIFFERENT_REMOTE_URL
echo rmdir /S /Q "%GIT_PULL_DIR%"
rmdir /S /Q "%GIT_PULL_DIR%"
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )

:GIT_PULL_DIR_NOT_EXIST
echo git clone %GIT_PULL_URL%
git clone %GIT_PULL_URL%
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )
endlocal

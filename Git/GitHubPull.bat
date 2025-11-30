@echo off
chcp 65001 > NUL

setlocal
set "GITHUB_USER=%~1"
set "GITHUB_REPOSITORY=%~2"
set "GITHUB_MASTER_BRANCH=%~3"
set "GITHUB_BRANCH=%~4"
set "GITHUB_BRANCH_ID=%~5"

call "%~dp0GitPull.bat" https://github.com/%GITHUB_USER%/%GITHUB_REPOSITORY% %GITHUB_MASTER_BRANCH%
if %ERRORLEVEL% neq 0 ( endlocal & exit /b 1 )

if "%GITHUB_BRANCH_ID%"=="" ( endlocal & exit /b 0 )

echo git -C %GITHUB_REPOSITORY% switch -C %GITHUB_BRANCH% %GITHUB_BRANCH_ID%
git -C %GITHUB_REPOSITORY% switch -C %GITHUB_BRANCH% %GITHUB_BRANCH_ID%
if %ERRORLEVEL% neq 0 ( pause & endlocal & exit /b 1 )

endlocal

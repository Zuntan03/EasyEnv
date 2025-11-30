@echo off
chcp 65001 > NUL

call "%~dp0SetUvPath.bat"
if %ERRORLEVEL% neq 0 ( exit /b 1 )

set PYTHONUTF8=1
call ".venv\Scripts\activate.bat"
if %ERRORLEVEL% neq 0 ( pause & exit /b 1 )

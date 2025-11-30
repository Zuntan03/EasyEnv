@echo off
chcp 65001 > NUL

@REM .python-version と pyproject.toml が必要

call "%~dp0SetUvPath.bat"
if %ERRORLEVEL% neq 0 ( exit /b 1 )

echo.
echo uv sync %*
uv sync %*
if %ERRORLEVEL% neq 0 ( pause & exit /b 1 )

set PYTHONUTF8=1
call ".venv\Scripts\activate.bat"
if %ERRORLEVEL% neq 0 ( pause & exit /b 1 )

@REM Tkinter 利用可能
@REM python -m tkinter

@REM C コンパイラ利用可能
@REM python -c "import sysconfig; print(sysconfig.get_paths()['include'])"

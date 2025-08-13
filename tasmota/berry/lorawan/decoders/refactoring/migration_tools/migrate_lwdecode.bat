@echo off
REM LoRaWAN Decoder Migration Script for Windows
REM Simple wrapper for Python migration tool

setlocal enabledelayedexpansion

set "REPO_PATH=C:\Project\tasmota\Tasmota"
set "SCRIPT_DIR=%~dp0"
set "MIGRATION_SCRIPT=%SCRIPT_DIR%migrate_lwdecode.py"

echo ================================
echo  LoRaWAN Decoder Migration Tool 
echo ================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not found or not in PATH
    echo Please install Python 3.7+ and add it to your PATH
    pause
    exit /b 1
)

REM Check if migration script exists
if not exist "%MIGRATION_SCRIPT%" (
    echo ERROR: Migration script not found at: %MIGRATION_SCRIPT%
    pause
    exit /b 1
)

echo Repository path: %REPO_PATH%
echo.

:menu
echo Migration Options:
echo 1. Dry Run (shows what would be changed)
echo 2. Execute Migration (actually performs the migration)
echo 3. Exit
echo.
set /p "CHOICE=Select option (1-3): "

if "%CHOICE%"=="1" goto dryrun
if "%CHOICE%"=="2" goto execute
if "%CHOICE%"=="3" goto exit
echo Invalid choice. Please select 1-3.
goto menu

:dryrun
echo.
echo Starting DRY RUN migration...
python "%MIGRATION_SCRIPT%" --repo-path "%REPO_PATH%" --dry-run
goto end

:execute
echo.
echo WARNING: This will modify your Tasmota repository files!
set /p "CONFIRM=Are you sure you want to proceed? (y/N): "
if not /i "%CONFIRM%"=="y" (
    echo Migration cancelled.
    goto end
)

echo.
echo Starting migration execution...
python "%MIGRATION_SCRIPT%" --repo-path "%REPO_PATH%" --execute
goto end

:exit
echo Exiting migration tool.
goto end

:end
echo.
pause
exit /b 0
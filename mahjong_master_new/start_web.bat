@echo off
setlocal

REM Double-click launcher for Mahjong Master New (Web)
cd /d "%~dp0"

set "HOST=127.0.0.1"
set "PORT=8090"
set "FLUTTER_WEB_RENDERER=html"

REM 1) Prefer flutter from PATH
for %%I in (flutter.bat) do set "FLUTTER_BAT=%%~$PATH:I"

REM 2) Fallback to your local Flutter SDK path (relative to this project)
if not defined FLUTTER_BAT (
  set "FLUTTER_BAT=%~dp0..\..\flutter\bin\flutter.bat"
)

if not exist "%FLUTTER_BAT%" (
  echo [ERROR] flutter.bat not found.
  echo Checked PATH and: "%~dp0..\..\flutter\bin\flutter.bat"
  echo.
  echo Please install Flutter or update this script path.
  pause
  exit /b 1
)

echo [INFO] Using Flutter: %FLUTTER_BAT%
echo [INFO] Project: %CD%
echo [INFO] Starting web app at http://%HOST%:%PORT%
echo.

REM Open browser a few seconds later to wait for server boot
start "" cmd /c "timeout /t 6 >nul && start http://%HOST%:%PORT%"

call "%FLUTTER_BAT%" pub get
if errorlevel 1 (
  echo.
  echo [ERROR] flutter pub get failed.
  pause
  exit /b 1
)

call "%FLUTTER_BAT%" run -d web-server --web-hostname %HOST% --web-port %PORT%

echo.
echo [INFO] Server stopped.
pause

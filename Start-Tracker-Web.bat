@echo off
setlocal
cd /d "%~dp0"

echo.
echo  Alpha Omega Tracker — local web server
echo  URL: http://localhost:3000/
echo  Use Chrome or Edge for this URL — Cursor's built-in browser often cannot finish Google sign-in.
echo  Sample data only ^(no Google^): http://localhost:3000/?demo=1
echo  Leave this window open while you use the app. Ctrl+C to stop.
echo.

where python >nul 2>&1
if %errorlevel%==0 (
  python -m http.server 3000
  goto :done
)

where py >nul 2>&1
if %errorlevel%==0 (
  py -3 -m http.server 3000
  goto :done
)

echo ERROR: Neither "python" nor "py" was found on PATH.
echo Install Python from https://www.python.org/ ^(check "Add to PATH"^) and run this again.
pause
exit /b 1

:done
if %errorlevel% neq 0 (
  echo.
  echo Server stopped. If you did not press Ctrl+C, port 3000 may be in use by another app.
  pause
)

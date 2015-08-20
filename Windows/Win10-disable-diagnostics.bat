@echo off

echo.
echo Removing Diagnostics Tracking Service...
sc stop DiagTrack > NUL 2>&1
sc delete DiagTrack

echo.
echo Disabling Diagnostics Tracking Logger...
echo "" >"%PROGRAMDATA%\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl"

echo.
echo Removing "Key Logger"...
sc stop dmwappushservice > NUL 2>&1
sc delete dmwappushservice

echo.
echo Disabling Telemetry...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /d 0 /f

echo.
pause

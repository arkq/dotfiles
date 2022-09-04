@echo off

echo.
echo Closing OneDrive process...
taskkill /f /im OneDrive.exe
timeout /t 5 /nobreak > NUL

echo.
echo Uninstalling OneDrive...
set x86="%SYSTEMROOT%\System32\OneDriveSetup.exe"
set x64="%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe"
if exist %x86% %x86% /uninstall
if exist %x64% %x64% /uninstall
timeout /t 5 /nobreak > NUL

echo.
echo Removing OneDrive leftovers...
rd "%USERPROFILE%\OneDrive" /Q /S
rd "%LOCALAPPDATA%\Microsoft\OneDrive" /Q /S
rd "%PROGRAMDATA%\Microsoft OneDrive" /Q /S
rd "C:\OneDriveTemp" /Q /S

echo.
echo Removing OneDrive from the Explorer Side Panel...
reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f

echo.
pause

@echo off
REM Create Windows Shortcut for Auto-Start
REM This script creates a shortcut to run the app automatically

echo Creating startup shortcut...

REM Create shortcut to run Hussam Clinic
setlocal enabledelayedexpansion

REM Path to save shortcut
set "ShortcutPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Hussam Clinic.lnk"

REM Create VBScript to make shortcut
set "VBSPath=%TEMP%\CreateShortcut.vbs"

(
echo Set oWS = WScript.CreateObject("WScript.Shell"^)
echo sLinkFile = "%ShortcutPath%"
echo Set oLink = oWS.CreateShortcut(sLinkFile^)
echo oLink.TargetPath = "D:\programms\hussam\run_app.bat"
echo oLink.WorkingDirectory = "D:\programms\hussam"
echo oLink.Description = "Hussam Clinic Application"
echo oLink.IconLocation = "D:\programms\hussam\build\windows\x64\runner\Release\hussam_clinc.exe"
echo oLink.Save
echo WScript.Echo "Shortcut created successfully!"
) > "%VBSPath%"

REM Run the VBScript
cscript.exe "%VBSPath%"

REM Clean up
del "%VBSPath%"

echo Shortcut has been created in your Startup folder!
echo التطبيق سيبدأ تلقائياً عند تشغيل الكمبيوتر! 

pause

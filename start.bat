@echo off
REM Simple Run Script - تشغيل بسيط

cd /d D:\programms\hussam

echo ========================================
echo Hussam Clinic - Starting Application
echo ========================================

REM Kill any running instances
taskkill /IM hussam_clinc.exe /F 2>nul

REM Try to run the existing executable
if exist "build\windows\x64\runner\Release\hussam_clinc.exe" (
    echo [OK] Executable found, starting app...
    start "Hussam Clinic" "build\windows\x64\runner\Release\hussam_clinc.exe"
    echo [OK] App has been launched!
    goto :end
) else (
    echo [WAIT] Building app... This may take 3-5 minutes...
    call flutter clean
    call flutter pub get
    call flutter build windows --release
    
    if exist "build\windows\x64\runner\Release\hussam_clinc.exe" (
        echo [OK] Build successful! Starting app...
        start "Hussam Clinic" "build\windows\x64\runner\Release\hussam_clinc.exe"
        echo [OK] App has been launched!
    ) else (
        echo [ERROR] Build failed! Executable not found.
        pause
        exit /b 1
    )
)

:end
echo.
echo ========================================
echo Application launcher has completed
echo ========================================
timeout /t 3

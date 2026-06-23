@echo off
set "SCRIPT=%~dp0startGameWithTemporarySettings.ps1"

start "" /b powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SCRIPT%" %*
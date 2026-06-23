@echo off

set "Dest=%USERPROFILE%\SquadSeed"
if not exist "%Dest%" mkdir "%Dest%"
copy /Y ".\files\*" "%Dest%\"

set "Script=%Dest%\startGameWithTemporarySettings.ps1"
set "Wrapper=%Dest%\launch.bat"
set "IconPath=%Dest%\SquadSeed.ico"

set "Lnk=%USERPROFILE%\Desktop\Squad Seed.lnk"

set /p "Ip=Enter Ip:Port [leave empty for SQEE: 84.200.135.21:7787]: "
if "%Ip%"=="" set "Ip=84.200.135.21:7787"
echo Ip:Port=%Ip%

echo Press your Squad Console Key
for /f "delims=" %%k in ('powershell -command "$key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyUp'); $key.VirtualKeyCode"') do set "ConsoleKey=%%k"
echo You pressed virtual key code: %ConsoleKey%

set "Args=-SendKeyStrokes -ConsoleKey %ConsoleKey% -IP "
powershell -NoProfile -Command "$W=New-Object -ComObject WScript.Shell; $L=$W.CreateShortcut('%Lnk%'); $L.TargetPath='%ComSpec%'; $L.Arguments='/c call '+[char]34+'%Wrapper%'+[char]34+' %Args%'+ [char]34+'%Ip%'+[char]34; $L.IconLocation='%IconPath%'; $L.WorkingDirectory='%Dest%'; $L.Save();"
echo Created Desktop Shortcut.

echo %Lnk%
copy "%Lnk%" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\"
echo Added to Start Menu
echo Press any key to exit...
pause >nul
exit /b
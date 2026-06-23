
# SquadSeed
Let's you easily create a shortcut on your desktop which allows you to automatically join a squad server with low graphics settings.
Includes a customizable powershellscript to launch games with a temporary .ini.

For alternatives see the bottom of the page.

## Prerequisites


Find the address of the Squad server you want to join. (Default is #SQEE. Find any on https://www.battlemetrics.com/servers/squad)

Make sure you know which key opens your console in squad. (You can adjust that ingame under ⚙ > CONTROLS > GENERAL > Console)
## Installation


Download this project
(Click  the green \<\> Code , then Download ZIP and extract that.)

Run install.bat

Follow the instructions on the command line.
(Wait, 
Enter address[optional, #SQEE is preset],
hit Enter, Wait,
Press Console Key)
## Usage/Examples

Launch the shortcut on your desktop called "Squad Seed".

Wait & Enjoy.

After you close the launched game, the original settings file will be reinstated.

(You can manually add that the shortcut to your steam library if you want, but make sure to afterwards go into the Properties of the shortcut on the desktop. From there, copy everything following cmd.exe into the Steam Launch Options of the newly created 'Steam Library Item'. You can find the icon in %userprofile%\SquadSeed which you also want to set as execution folder.)


## Documentation

- If the server address changes, you need to rerun the install.bat.


- If the script aborts, it usually leaves behind a backup called GameUserSettings.ini.bak of the original settings file.
The next time the script is launched it detects this remaining backup and handles it carefully: Wait for Squad to launch. After quitting Squad and waiting for 10 seconds, the normal settings file should be restored.


## Lessons Learned

Originally I wanted to read the ConsoleKey from the Input.ini but I gave up on that, it didn't seem reliable to me.

If you just want a helping hand with switching Setting Files, you can also code a minimal Batch file yourself: https://pastebin.com/YPe1LY6z

According to reddit, it was once possible to directly join a server using steam launch options, I wasn't able to get that to work, neither -safe for low graphics worked out. (The only option that I successfully tested was -noaudio.) Let me know if you manage to get this simple solution to work.

## Alternative without powershell usage

Instead of installing this project or using above link, you can install AutoHotkey and use the script alternativeAutoHotkeyScript.ahk 
This is a simple translation of the powershell script, preset to #SQEE.

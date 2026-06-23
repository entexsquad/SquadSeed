#Requires AutoHotkey v2.0
#SingleInstance Force

; Parameters
SettingsFile := A_AppData "\..\Local\SquadGame\Saved\Config\Windows\GameUserSettings.ini"
GameExePath := "steam://rungameid/393380"
SendKeyStrokes := false
WindowClass := "UnrealWindow"
WindowTitle := "SquadGame  "
ConsoleKey := "{#}"
; # on German QWERTY
IP := "84.200.135.21:7787"
AppendLines :=
(
"[/Script/Squad.SQGameUserSettings]
UnfocusedVolumeMultiplier=0.0
ScreenSharpening=(Value=0)
ScreenPercentage=(Value=33)
MaxAnisotropy=(Value=4)
UpscaleMode=0
MenuFrameRateLimit=30.000000
AntiAliasingMode=(Value=0)
MaterialQuality=(Value=0)
bUncapTexturePoolSize=False
AmbientOcclusion=(Value=0)
SelectedFrameGeneration=NONE
NISSharpness=0.000000
DLSSFrameGenerationMode=Off
ReflexMode=Off
OceanQuality=(Value=0)
WakeSim=(Value=0)
bUseVSync=False
ResolutionSizeX=1024
ResolutionSizeY=768
LastUserConfirmedResolutionSizeX=1024
LastUserConfirmedResolutionSizeY=768
FullscreenMode=2
LastConfirmedFullscreenMode=2
FrameRateLimit=30.000000

[ScalabilityGroups]
sg.ResolutionQuality=50
sg.ViewDistanceQuality=0
sg.AntiAliasingQuality=0
sg.ShadowQuality=0
sg.GlobalIlluminationQuality=0
sg.ReflectionQuality=0
sg.PostProcessQuality=0
sg.TextureQuality=0
sg.EffectsQuality=0
sg.FoliageQuality=0
sg.ShadingQuality=0
sg.LandscapeQuality=0"
)

; initialbackup
if !FileExist(SettingsFile ".ahkinitialbackup"){
    FileCopy(SettingsFile, SettingsFile ".ahkinitialbackup")
}
; Backup handling
if (FileExist(SettingsFile ".bak")) {
    scriptLeaf := A_ScriptName
    dir := A_AppData "\..\Local\SquadGame\Saved\Config\Windows\"
    base := "Backup - " scriptLeaf " didnt exit properly and overwrote this GameUserSettings.ini - "
    ext := ".bak"
    n := 1
    loop {
        name := base n ext
        path := dir name
        if (!FileExist(path)) {
            break
        }
        n++
    }
    FileMove(SettingsFile, path)
    FileMove(SettingsFile ".bak", SettingsFile)
}

; Backup original settings
FileCopy(SettingsFile, SettingsFile ".bak", true)

; Append low settings
FileAppend(AppendLines, SettingsFile)

; Start game
gameProc := Run(GameExePath)
timeout := 42000
startTime := A_TickCount
while (A_TickCount - startTime < timeout) {
    if (ProcessExist("SquadGame-Win64-Shipping.exe")) {
    break
    }
    Sleep(69)
}
; should be decreased:
Sleep(42000)

; Find window
; hwnd := WinExist(WindowClass, WindowTitle)
hwnd := WinExist("ahk_exe SquadGame-Win64-Shipping.exe")
if !hwnd {
    MsgBox("Window not found!")
    ExitApp
}
; MsgBox("Window found! HWND: " hwnd)


; ControlSendText(WindowClass, "1","ahk_exe SquadGame-Win64-Shipping.exe", "", "NA")
ControlSend("1", hwnd)

; Wait for main menu
Sleep(3000)

; custom Send keys sequence)
; ControlSend("{#}jalol{Enter}",hwnd)#
ControlSend(ConsoleKey,hwnd)
; it sends the key into the console aswell, this time I'll just use backspace lol
Sleep(50)
ControlSend("{Backspace}",hwnd)
Sleep(50)
ControlSend("open ",hwnd)
Sleep(20)
ControlSendText(IP, hwnd)
; old version:
if !true{
; need to handle ":" somehow... ah I think it's partly because of AHK pressing shift to type it and thus messing up the following numbers
ipArr := StrSplit(IP,":")
ControlSend(ipArr[1],hwnd)
Sleep(100)
ControlSendText(":",hwnd)
Sleep(100)
ControlSend(ipArr[2],hwnd)
}
Sleep(100)
ControlSend("{Enter}",hwnd)

; Check if process exists
maySkip := (ProcessExist("SquadGame-Win64-Shipping.exe") != 0)
; Wait while window exists
while (WinExist(hwnd)) {
    Sleep(500)

}

; Additional wait logic
if (maySkip) {
    timeout := 7000
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (!ProcessExist("SquadGame-Win64-Shipping.exe")) {
            break
        }
        Sleep(69)
    }
} else {
    Sleep(5000)
}

; Restore original settings
FileMove(SettingsFile ".bak", SettingsFile, true)


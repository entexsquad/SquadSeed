param(
    [string]$SettingsFile = "$env:LOCALAPPDATA\SquadGame\Saved\Config\Windows\GameUserSettings.ini",
    [string]$GameExePath = "steam://rungameid/393380",
    
    #use -SendKeyStrokes in the call to send keystrokes to that window:
    [switch]$SendKeyStrokes,
    [string]$WindowClass = "UnrealWindow",
    [string]$WindowTitle = "SquadGame  ",
    
    [int]$ConsoleKey = 191,
    # (191 is # on a standard German QWERTY keyboard)
    #On US keyboards, the backtick key is the OEM_3 key. Virtual-key code: VK_OEM_3 = 0xC0 change to that if you use default console key- Instead of above, use:
    #[int]$ConsoleKey = 0xC0,
    
    [string]$IP="12345:67",
    [object[]]$SendKeysSequence = @(
        $ConsoleKey,
        0x20,
        "Open ",
        $IP,
        0x0D
    ),
    # 0x0D is the standard virtual-key code for the Enter/Return key, 32 / 0x20 is space which is a little hack to 'get focus' in the console
    
    $AppendLines = @'

[/Script/Squad.SQGameUserSettings]
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
sg.LandscapeQuality=0
'@
)

#make SendMessage, FindWindow & IsWindow available through C#
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class Win32 {
  [DllImport("user32.dll")] public static extern bool SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
  [DllImport("user32.dll")] public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
  [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr hWnd);
}
"@

#intelligent wrapper function ready for squad
function Post-Keys {
  param(
    [Parameter(Mandatory=$true)]
    [IntPtr] $Hwnd,

    [Parameter(Mandatory=$true)]
    $Message
  )

  $WM_KEYDOWN = 0x0100
  $WM_KEYUP   = 0x0101
  $WM_CHAR    = 0x0102

  if ($Message -is [int]) {
    $vk = [IntPtr]$Message
    [void][Win32]::SendMessage($Hwnd, $WM_KEYDOWN, $vk, [IntPtr]::Zero)
    #when using PostMessage instead of SendMessage, a delay is needed:
    #Start-Sleep -Milliseconds 5
    [void][Win32]::SendMessage($Hwnd, $WM_KEYUP,   $vk, [IntPtr]::Zero)
  }
  else {
    $s = [string]$Message
    Start-Sleep -Milliseconds 100
    foreach ($ch in $s.ToCharArray()) {
      $code = [int][char]$ch
      [void][Win32]::SendMessage($Hwnd, $WM_CHAR, [IntPtr]$code, [IntPtr]::Zero)
      Start-Sleep -Milliseconds 50
    }
  }
}

#create a backup if the script wasn't run before
if (!(Test-Path "$SettingsFile.ps1initialbackup")){
    Copy-Item $SettingsFile "$SettingsFile.ps1initialbackup" -ErrorAction Stop
}

if (Test-Path -Path "$SettingsFile.bak") {
  $scriptLeaf = Split-Path -Leaf $MyInvocation.MyCommand.Path
  $dir  = Split-Path -Parent $SettingsFile
  $base = "Backup - $scriptLeaf didnt exit properly and overwrote this GameUserSettings.ini - "
  $ext  = ".bak"
  $n = 1
  do {
    $name = "${base}$n$ext"
    $path = Join-Path $dir $name
    $n++
  } while (Test-Path -Path $path)

  Rename-Item -Path $SettingsFile -NewName $name
  Rename-Item -Path "$SettingsFile.bak" (Split-Path -Leaf $SettingsFile)
}

#Backup original settings & abort when failing
Copy-Item $SettingsFile "$SettingsFile.bak" -Force -ErrorAction Stop

#Append Low Settings (of lines with identical keys, the last one seems to take priority)
Add-Content -Path $SettingsFile -Value $AppendLines

#gameProc is only the PID of the easyAntiCheat or whatever
$gameProc = Start-Process -FilePath $GameExePath -PassThru -ErrorAction Stop
Start-Sleep -Seconds 20
$timeout = 40
$sw = [Diagnostics.Stopwatch]::StartNew()
while($sw.Elapsed.TotalSeconds -lt $timeout) {
    Start-Sleep -Milliseconds 500
    $hwnd = [Win32]::FindWindow($WindowClass,$WindowTitle)
    if([Win32]::IsWindow($hwnd)){ break}
    }
#adding extra wait time because above also identifies launcher, may improve this sometime else.
Start-Sleep -Seconds 42
$hwnd = [Win32]::FindWindow($WindowClass,$WindowTitle)
Post-Keys $hwnd 0x20

#Wait for Main Menu to load:
Start-Sleep -Seconds 3

foreach($msg in $SendKeysSequence){
    Post-Keys $hwnd $msg
}

$maySkip=Get-Process -Name 'SquadGame-Win64-Shipping' -ErrorAction SilentlyContinue

#Wait while the game is still running, check twice a second..
while([Win32]::IsWindow($hwnd)) {
    Start-Sleep -Milliseconds 500
    }

#instead of the following, we could just always wait for 7 seconds. If the pc stopped or the script run again sooner, it should fix itself anyways
if($maySkip){
  #after the window is exited, the game still runs up to a few seconds, usually around 1-3
  $timeout = 7
  $sw = [Diagnostics.Stopwatch]::StartNew()
  
  while ($sw.Elapsed.TotalSeconds -lt $timeout) {
    $p = Get-Process -Name 'SquadGame-Win64-Shipping' -ErrorAction SilentlyContinue
    if (-not $p) { break }
  
    Start-Sleep -Milliseconds 69
}
}else{
Start-Sleep -Seconds 5
}
Move-Item -Path "$SettingsFile.bak" -Destination $SettingsFile -Force -ErrorAction Stop
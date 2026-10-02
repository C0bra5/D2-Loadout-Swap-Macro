#Requires AutoHotkey v2.0
#SingleInstance Force

; Configure system-wide coordinate and input modes
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
SendMode("Input")
SetKeyDelay(-1)
SetMouseDelay(-1)
SetDefaultMouseSpeed(0)
SetWinDelay(-1)
SetControlDelay(-1)

; Include components
#Include "Coordinates.ahk"
#Include "Timer.ahk"
#Include "Config.ahk"
#Include "Swapper.ahk"
#Include "Hotkeys.ahk"
#Include "UI.ahk"

; Initialize precision timer and configuration
HighResTimer.Initialize()
ConfigManager.Load()

; Register hotkeys
HotkeysManager.RegisterActivePreset()
HotkeysManager.RegisterExitHotkey()
HotkeysManager.RegisterReloadHotkey()

; Timer teardown on exit
OnExit((*) => HighResTimer.Cleanup())

; Check command-line arguments for minimized startup
startMode := ""
for arg in A_Args {
    if (arg = "/min" || arg = "/minimized")
        startMode := "Minimize"
}

; Launch GUI
UI.Show(startMode)

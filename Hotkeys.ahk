#Requires AutoHotkey v2.0

class HotkeysManager {
    static RegisteredProfileHotkeys := []
    static CurrentExitHotkey := ""
    static CurrentReloadHotkey := ""

    static RegisterActivePreset() {
        ; Disable previously registered profile hotkeys
        HotIfWinActive("ahk_exe destiny2.exe")
        for key in this.RegisteredProfileHotkeys {
            try Hotkey("*" key, "Off")
            try Hotkey(key, "Off")
        }
        this.RegisteredProfileHotkeys := []

        ; Register all valid hotkeys in the currently active preset
        activeProfiles := ConfigManager.Presets[ConfigManager.ActivePreset]
        for profile in activeProfiles {
            key := Trim(profile.Keybind)
            ; Strict safeguard: Escape is never allowed as a trigger hotkey
            if (key != "" && StrLower(key) != "escape" && StrLower(key) != "esc") {
                try {
                    ; Fix: .Bind() permanently binds this specific profile instance
                    triggerFn := Swapper.Trigger.Bind(Swapper, profile)
                    Hotkey("*" key, triggerFn, "On")
                    this.RegisteredProfileHotkeys.Push(key)
                } catch {
                    ; Silently handle invalid hotkey format
                }
            }
        }

        ; Reset context condition
        HotIfWinActive()
    }

    static RegisterExitHotkey() {
        ; Unregister previous exit hotkey
        if (this.CurrentExitHotkey != "") {
            HotIfWinNotActive("Destiny 2 Loadout Swapper")
            try Hotkey("*" this.CurrentExitHotkey, "Off")
            try Hotkey(this.CurrentExitHotkey, "Off")
            HotIfWinNotActive()
            this.CurrentExitHotkey := ""
        }

        exitKey := Trim(ConfigManager.ExitHotkey)
        if (exitKey != "" && StrLower(exitKey) != "escape" && StrLower(exitKey) != "esc") {
            try {
                ; Fix: Only active when the Swapper UI window is NOT focused
                HotIfWinNotActive("Destiny 2 Loadout Swapper")
                Hotkey("*" exitKey, (*) => this.HandleExit(), "On")
                HotIfWinNotActive()
                this.CurrentExitHotkey := exitKey
            } catch {
                ; Silently handle invalid keybind
            }
        }
    }

    static HandleExit(*) {
        if (Swapper.IsSwapping) {
            Swapper.CancelRequested := true
            ToolTip()
            Swapper.IsSwapping := false
        }
        ExitApp()
    }

    static RegisterReloadHotkey() {
        ; Unregister previous reload hotkey
        if (this.CurrentReloadHotkey != "") {
            HotIf((*) => Swapper.IsSwapping)
            try Hotkey("*" this.CurrentReloadHotkey, "Off")
            try Hotkey(this.CurrentReloadHotkey, "Off")
            HotIf()

            HotIfWinNotActive("Destiny 2 Loadout Swapper")
            try Hotkey("*" this.CurrentReloadHotkey, "Off")
            try Hotkey(this.CurrentReloadHotkey, "Off")
            HotIfWinNotActive()

            this.CurrentReloadHotkey := ""
        }

        reloadKey := Trim(ConfigManager.ReloadHotkey)
        if (reloadKey = "")
            reloadKey := "F5"

        try {
            ; While swapping, reloadKey cancels the swap and reloads
            HotIf((*) => Swapper.IsSwapping)
            Hotkey("*" reloadKey, (*) => Swapper.Cancel(), "On")
            ; Escape always functions as a safety cancel during swapping
            Hotkey("*Escape", (*) => Swapper.Cancel(), "On")
            HotIf()

            ; When NOT swapping and Swapper UI is not active, reloadKey reloads the script
            ; (unless set to Escape, which is reserved for game menus when idle)
            if (StrLower(reloadKey) != "escape" && StrLower(reloadKey) != "esc") {
                HotIfWinNotActive("Destiny 2 Loadout Swapper")
                Hotkey("*" reloadKey, (*) => Reload(), "On")
                HotIfWinNotActive()
            }

            this.CurrentReloadHotkey := reloadKey
        } catch {
            ; Silently handle invalid keybind
        }
    }

    static GetActiveListeningCount() {
        return this.RegisteredProfileHotkeys.Length
    }
}

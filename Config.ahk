#Requires AutoHotkey v2.0

class ProfileData {
    Name := "1"
    Keybind := ""
    ClickDelay := 100
    TargetSwaps := 80
    SelectedGear := "Helmet"
    LoadoutGrid := []

    Clone() {
        p := ProfileData()
        p.Name := this.Name
        p.Keybind := this.Keybind
        p.ClickDelay := this.ClickDelay
        p.TargetSwaps := this.TargetSwaps
        p.SelectedGear := this.SelectedGear
        p.LoadoutGrid := this.LoadoutGrid.Clone()
        return p
    }
}

class ConfigManager {
    static IniPath := A_ScriptDir "\config.ini"
    static ActivePreset := "A"
    static ActiveProfileIndex := 1
    static SelectedResolution := "2560x1440"
    static ExitHotkey := "F4"
    static ReloadHotkey := "F5"
    static Presets := Map("A", [], "B", [], "C", [])

    ; Centralized numeric bounds
    static MinClickDelay := 100
    static MaxClickDelay := 500
    static DefaultClickDelay := 100

    static MinTargetSwaps := 1
    static MaxTargetSwaps := 1000
    static DefaultTargetSwaps := 80

    static ClampClickDelay(val) {
        if !IsInteger(val)
            return this.DefaultClickDelay
        num := Integer(val)
        return Max(this.MinClickDelay, Min(this.MaxClickDelay, num))
    }

    static ClampTargetSwaps(val) {
        if !IsInteger(val)
            return this.DefaultTargetSwaps
        num := Integer(val)
        return Max(this.MinTargetSwaps, Min(this.MaxTargetSwaps, num))
    }

    static RenumberProfiles(presetName) {
        if !this.Presets.Has(presetName)
            return
        profiles := this.Presets[presetName]
        for idx, profile in profiles {
            profile.Name := String(idx)
        }
    }

    static AddProfile(presetName) {
        if !this.Presets.Has(presetName)
            this.Presets[presetName] := []

        newProfile := ProfileData()
        this.Presets[presetName].Push(newProfile)
        this.RenumberProfiles(presetName)
        return this.Presets[presetName].Length
    }

    static DeleteProfile(presetName, index) {
        if !this.Presets.Has(presetName)
            return false

        profiles := this.Presets[presetName]
        if profiles.Length <= 1
            return false ; Must keep at least 1 profile

        if (index < 1 || index > profiles.Length)
            return false

        profiles.RemoveAt(index)
        this.RenumberProfiles(presetName)
        return true
    }

    static GetActiveProfile() {
        if !this.Presets.Has(this.ActivePreset)
            this.Presets[this.ActivePreset] := [ProfileData()]

        profiles := this.Presets[this.ActivePreset]
        if (this.ActiveProfileIndex < 1 || this.ActiveProfileIndex > profiles.Length)
            this.ActiveProfileIndex := 1

        return profiles[this.ActiveProfileIndex]
    }

    static Load() {
        ini := this.IniPath

        ; Global settings
        this.ActivePreset := IniRead(ini, "Global", "ActivePreset", "A")
        if (this.ActivePreset != "A" && this.ActivePreset != "B" && this.ActivePreset != "C")
            this.ActivePreset := "A"

        this.ActiveProfileIndex := Integer(IniRead(ini, "Global", "ActiveProfileIndex", 1))
        this.SelectedResolution := IniRead(ini, "Global", "SelectedResolution", "1920x1080")
        this.ExitHotkey := IniRead(ini, "Global", "ExitHotkey", "F4")
        this.ReloadHotkey := IniRead(ini, "Global", "ReloadHotkey", "F5")

        ; Load presets A, B, C
        for presetKey in ["A", "B", "C"] {
            this.Presets[presetKey] := []
            count := Integer(IniRead(ini, "Preset_" presetKey, "ProfileCount", 0))

            if (count < 1) {
                ; Default: create 1 profile
                this.Presets[presetKey].Push(ProfileData())
            } else {
                loop count {
                    sec := "Preset_" presetKey "_Profile_" A_Index
                    p := ProfileData()
                    p.Name := String(A_Index)
                    p.Keybind := IniRead(ini, sec, "Keybind", "")
                    p.ClickDelay := this.ClampClickDelay(IniRead(ini, sec, "ClickDelay", this.DefaultClickDelay))
                    p.TargetSwaps := this.ClampTargetSwaps(IniRead(ini, sec, "TargetSwaps", this.DefaultTargetSwaps))
                    p.SelectedGear := IniRead(ini, sec, "SelectedGear", "Helmet")

                    gridStr := IniRead(ini, sec, "LoadoutGrid", "")
                    p.LoadoutGrid := []
                    if (gridStr != "") {
                        for slotStr in StrSplit(gridStr, ",") {
                            trimmed := Trim(slotStr)
                            if (IsInteger(trimmed)) {
                                slotNum := Integer(trimmed)
                                if (slotNum >= 1 && slotNum <= 20)
                                    p.LoadoutGrid.Push(slotNum)
                            }
                        }
                    }

                    this.Presets[presetKey].Push(p)
                }
            }

            this.RenumberProfiles(presetKey)
        }

        ; Validate active profile index
        if (this.ActiveProfileIndex < 1 || this.ActiveProfileIndex > this.Presets[this.ActivePreset].Length)
            this.ActiveProfileIndex := 1
    }

    static Save() {
        ini := this.IniPath

        ; Save Global settings
        IniWrite(this.ActivePreset, ini, "Global", "ActivePreset")
        IniWrite(this.ActiveProfileIndex, ini, "Global", "ActiveProfileIndex")
        IniWrite(this.SelectedResolution, ini, "Global", "SelectedResolution")
        IniWrite(this.ExitHotkey, ini, "Global", "ExitHotkey")
        IniWrite(this.ReloadHotkey, ini, "Global", "ReloadHotkey")

        ; Save Presets A, B, C
        for presetKey in ["A", "B", "C"] {
            profiles := this.Presets[presetKey]
            oldCount := Integer(IniRead(ini, "Preset_" presetKey, "ProfileCount", 0))

            IniWrite(profiles.Length, ini, "Preset_" presetKey, "ProfileCount")

            for idx, p in profiles {
                sec := "Preset_" presetKey "_Profile_" idx
                IniWrite(p.Name, ini, sec, "Name")
                IniWrite(p.Keybind, ini, sec, "Keybind")
                IniWrite(p.ClickDelay, ini, sec, "ClickDelay")
                IniWrite(p.TargetSwaps, ini, sec, "TargetSwaps")
                IniWrite(p.SelectedGear, ini, sec, "SelectedGear")

                gridStr := ""
                for sIdx, slot in p.LoadoutGrid {
                    gridStr .= (sIdx > 1 ? "," : "") slot
                }
                IniWrite(gridStr, ini, sec, "LoadoutGrid")
            }

            ; Clean up stale profile sections if count decreased
            if (oldCount > profiles.Length) {
                loop (oldCount - profiles.Length) {
                    staleIdx := profiles.Length + A_Index
                    sec := "Preset_" presetKey "_Profile_" staleIdx
                    try IniDelete(ini, sec)
                }
            }
        }
    }
}

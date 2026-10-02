#Requires AutoHotkey v2.0

class UI {
    static GuiObj := ""
    static RadioPresets := Map()
    static DDLResolution := ""
    static DDLProfile := ""
    static BtnDeleteProfile := ""
    static HKTrigger := ""
    static EditClickDelay := ""
    static EditTargetSwaps := ""
    static DDLGearSlot := ""
    static GridCheckboxes := Map()
    static HKReload := ""
    static HKExit := ""
    static TextStatus := ""

    static Show(startMode := "") {
        if (this.GuiObj != "") {
            if (startMode = "Minimize") {
                this.GuiObj.Show("Minimize")
            } else {
                this.GuiObj.Show()
            }
            return
        }

        g := Gui("-MaximizeBox", "Destiny 2 Loadout Swapper")
        this.GuiObj := g
        g.SetFont("s9", "Segoe UI")

        ; -------------------------------------------------------------
        ; Top Section: Presets & Resolution
        ; -------------------------------------------------------------
        g.Add("GroupBox", "x10 y10 w445 h60", "Preset & Resolution")

        this.RadioPresets["A"] := g.Add("Radio", "x25 y32 w75 h24", "Preset A")
        this.RadioPresets["B"] := g.Add("Radio", "x105 y32 w75 h24", "Preset B")
        this.RadioPresets["C"] := g.Add("Radio", "x185 y32 w75 h24", "Preset C")

        this.RadioPresets["A"].OnEvent("Click", (*) => this.OnPresetChanged("A"))
        this.RadioPresets["B"].OnEvent("Click", (*) => this.OnPresetChanged("B"))
        this.RadioPresets["C"].OnEvent("Click", (*) => this.OnPresetChanged("C"))

        g.Add("Text", "x275 y18 w160 h16", "Game Resolution:")
        resList := Coordinates.GetSupportedList()
        this.DDLResolution := g.Add("DropDownList", "x275 y34 w165", resList)
        this.DDLResolution.OnEvent("Change", (*) => this.OnResolutionChanged())

        ; -------------------------------------------------------------
        ; Profiles Bar
        ; -------------------------------------------------------------
        g.Add("GroupBox", "x10 y78 w445 h58", "Profiles in Active Preset")
        g.Add("Text", "x25 y103 w45 h20", "Profile:")
        this.DDLProfile := g.Add("DropDownList", "x75 y99 w195")
        this.DDLProfile.OnEvent("Change", (*) => this.OnProfileSelected())

        btnNew := g.Add("Button", "x280 y98 w75 h26", "+ New")
        btnNew.OnEvent("Click", (*) => this.OnNewProfile())

        this.BtnDeleteProfile := g.Add("Button", "x362 y98 w75 h26", "- Delete")
        this.BtnDeleteProfile.OnEvent("Click", (*) => this.OnDeleteProfile())

        ; -------------------------------------------------------------
        ; Profile Configuration Panel
        ; -------------------------------------------------------------
        g.Add("GroupBox", "x10 y144 w445 h360", "Profile Configuration")

        ; Trigger Hotkey
        g.Add("Text", "x25 y173 w95 h20", "Trigger Hotkey:")
        this.HKTrigger := g.Add("Hotkey", "x125 y170 w180 h24")
        this.HKTrigger.OnEvent("Change", (*) => this.OnHotkeyControlChanged())

        btnClearBind := g.Add("Button", "x315 y169 w125 h26", "Clear Bind")
        btnClearBind.OnEvent("Click", (*) => this.OnClearBind())

        ; Click Delay
        g.Add("Text", "x25 y207 w95 h20", "Click Delay:")
        this.EditClickDelay := g.Add("Edit", "x125 y204 w70 h22 +Number", ConfigManager.DefaultClickDelay)
        g.Add("UpDown", "Range" ConfigManager.MinClickDelay "-" ConfigManager.MaxClickDelay, ConfigManager.DefaultClickDelay)
        g.Add("Text", "x205 y207 w140 h20 cGray", Format("ms (Min {1}, Max {2})", ConfigManager.MinClickDelay, ConfigManager.MaxClickDelay))

        ; Target Swaps
        g.Add("Text", "x25 y241 w95 h20", "Target Swaps:")
        this.EditTargetSwaps := g.Add("Edit", "x125 y238 w70 h22 +Number", ConfigManager.DefaultTargetSwaps)
        g.Add("UpDown", "Range" ConfigManager.MinTargetSwaps "-" ConfigManager.MaxTargetSwaps, ConfigManager.DefaultTargetSwaps)
        g.Add("Text", "x205 y241 w140 h20 cGray", Format("swaps (Min {1}, Max {2})", ConfigManager.MinTargetSwaps, ConfigManager.MaxTargetSwaps))

        ; Monitored Gear Slot
        g.Add("Text", "x25 y275 w95 h20", "Gear Slot:")
        this.DDLGearSlot := g.Add("DropDownList", "x125 y272 w130", ["Helmet", "Arms", "Chest", "Legs", "Class Item"])

        ; Numbered 4x5 Loadout Grid
        g.SetFont("bold")
        g.Add("Text", "x25 y310 w350 h18", "Loadout Sequence (Ascending 4x5 Grid):")
        g.SetFont("norm")

        for r in [1, 2, 3, 4, 5] {
            for c in [1, 2, 3, 4] {
                idx := (r - 1) * 4 + c
                xCol := 30 + (c - 1) * 102
                yRow := 336 + (r - 1) * 26

                ; Number label to the left of the checkbox
                g.Add("Text", Format("x{} y{} w24 h20 Right", xCol, yRow + 2), idx ":")
                ; Checkbox
                this.GridCheckboxes[idx] := g.Add("Checkbox", Format("x+4 y{} w22 h20", yRow))
            }
        }

        btnClearGrid := g.Add("Button", "x25 y472 w110 h24", "Clear All Slots")
        btnClearGrid.OnEvent("Click", (*) => this.OnClearGrid())

        ; -------------------------------------------------------------
        ; Footer: Global Exit/Reload Keys, Save, Status
        ; -------------------------------------------------------------
        g.Add("GroupBox", "x10 y512 w445 h96", "Global Settings & Actions")

        ; Row 1: Reload Script Key and Reload Button
        g.Add("Text", "x25 y537 w100 h20", "Reload Script Key:")
        this.HKReload := g.Add("Hotkey", "x125 y534 w85 h24", ConfigManager.ReloadHotkey)
        this.HKReload.OnEvent("Change", (*) => this.OnReloadHotkeyChanged())

        btnReload := g.Add("Button", "x215 y533 w52 h26", "Reload")
        btnReload.OnEvent("Click", (*) => this.OnReloadScript())

        ; Save Settings button (prominent on the right)
        btnSave := g.Add("Button", "x275 y533 w165 h57 +Default", "Save Settings")
        btnSave.OnEvent("Click", (*) => this.OnSaveSettings())

        ; Row 2: Exit Script Key
        g.Add("Text", "x25 y570 w100 h20", "Exit Script Key:")
        this.HKExit := g.Add("Hotkey", "x125 y567 w85 h24", ConfigManager.ExitHotkey)
        this.HKExit.OnEvent("Change", (*) => this.OnExitHotkeyChanged())

        this.TextStatus := g.Add("Text", "x12 y618 w440 h20 cGray", "Status: Ready")

        g.OnEvent("Close", (*) => ExitApp())

        ; Populate initial UI values
        this.RefreshAll()

        if (startMode = "Minimize") {
            g.Show("Minimize")
        } else {
            g.Show("w465 h645")
        }
    }

    static RefreshAll() {
        ; Set radio buttons
        for key, radio in this.RadioPresets {
            radio.Value := (key == ConfigManager.ActivePreset)
        }

        ; Set Resolution dropdown
        this.DDLResolution.Text := ConfigManager.SelectedResolution

        ; Refresh profile list and current profile
        this.RefreshProfileDropdown()
        this.LoadActiveProfileToUI()
        this.HKExit.Value := ConfigManager.ExitHotkey
        this.HKReload.Value := ConfigManager.ReloadHotkey
        this.UpdateStatusBar()
    }

    static RefreshProfileDropdown() {
        profiles := ConfigManager.Presets[ConfigManager.ActivePreset]
        items := []
        for p in profiles {
            keyText := p.Keybind != "" ? p.Keybind : "Unbound"
            items.Push("Profile " p.Name " [" keyText "]")
        }

        this.DDLProfile.Delete()
        this.DDLProfile.Add(items)
        if (ConfigManager.ActiveProfileIndex < 1 || ConfigManager.ActiveProfileIndex > profiles.Length)
            ConfigManager.ActiveProfileIndex := 1
        this.DDLProfile.Choose(ConfigManager.ActiveProfileIndex)

        this.BtnDeleteProfile.Enabled := (profiles.Length > 1)
    }

    static LoadActiveProfileToUI() {
        p := ConfigManager.GetActiveProfile()

        ; Keybind display
        this.HKTrigger.Value := ""
        if (p.Keybind != "") {
            try this.HKTrigger.Value := p.Keybind
        }

        ; Numeric inputs
        this.EditClickDelay.Value := p.ClickDelay
        this.EditTargetSwaps.Value := p.TargetSwaps

        ; Gear dropdown
        gearName := p.SelectedGear
        if (gearName = "ClassItem")
            gearName := "Class Item"
        try this.DDLGearSlot.Text := gearName

        ; Checkboxes
        enabledMap := Map()
        for slot in p.LoadoutGrid {
            enabledMap[slot] := true
        }

        for idx, cb in this.GridCheckboxes {
            cb.Value := enabledMap.Has(idx) ? 1 : 0
        }
    }

    static SaveUIToActiveProfile() {
        p := ConfigManager.GetActiveProfile()

        ; Clamped numeric inputs
        p.ClickDelay := ConfigManager.ClampClickDelay(this.EditClickDelay.Value)
        p.TargetSwaps := ConfigManager.ClampTargetSwaps(this.EditTargetSwaps.Value)
        this.EditClickDelay.Value := p.ClickDelay
        this.EditTargetSwaps.Value := p.TargetSwaps

        ; Gear slot
        gearVal := this.DDLGearSlot.Text
        if (gearVal = "Class Item")
            gearVal := "ClassItem"
        p.SelectedGear := gearVal

        ; 4x5 Grid
        p.LoadoutGrid := []
        for idx, cb in this.GridCheckboxes {
            if (cb.Value == 1)
                p.LoadoutGrid.Push(idx)
        }
    }

    static OnPresetChanged(newPreset) {
        if (newPreset == ConfigManager.ActivePreset)
            return

        this.SaveUIToActiveProfile()
        ConfigManager.ActivePreset := newPreset
        ConfigManager.ActiveProfileIndex := 1

        this.RefreshProfileDropdown()
        this.LoadActiveProfileToUI()

        ; Update hotkeys to only listen to the newly active preset
        HotkeysManager.RegisterActivePreset()
        this.UpdateStatusBar()
    }

    static OnProfileSelected() {
        newIdx := this.DDLProfile.Value
        if (newIdx == ConfigManager.ActiveProfileIndex || newIdx < 1)
            return

        this.SaveUIToActiveProfile()
        ConfigManager.ActiveProfileIndex := newIdx
        this.LoadActiveProfileToUI()
    }

    static OnNewProfile() {
        this.SaveUIToActiveProfile()
        newIdx := ConfigManager.AddProfile(ConfigManager.ActivePreset)
        ConfigManager.ActiveProfileIndex := newIdx

        this.RefreshProfileDropdown()
        this.LoadActiveProfileToUI()
        HotkeysManager.RegisterActivePreset()
        this.UpdateStatusBar()
    }

    static OnDeleteProfile() {
        profiles := ConfigManager.Presets[ConfigManager.ActivePreset]
        if (profiles.Length <= 1) {
            MsgBox("Each preset must keep at least 1 profile.", "Destiny 2 Swapper", "Icon!")
            return
        }

        targetIdx := ConfigManager.ActiveProfileIndex
        ConfigManager.DeleteProfile(ConfigManager.ActivePreset, targetIdx)

        if (ConfigManager.ActiveProfileIndex > ConfigManager.Presets[ConfigManager.ActivePreset].Length)
            ConfigManager.ActiveProfileIndex := ConfigManager.Presets[ConfigManager.ActivePreset].Length

        this.RefreshProfileDropdown()
        this.LoadActiveProfileToUI()
        HotkeysManager.RegisterActivePreset()
        this.UpdateStatusBar()
    }

    static OnHotkeyControlChanged() {
        val := this.HKTrigger.Value
        ; Guard against binding Escape
        if (StrLower(val) = "escape" || StrLower(val) = "esc") {
            this.HKTrigger.Value := ""
            MsgBox("Escape cannot be bound. It is reserved for cancelling active swaps.", "Destiny 2 Swapper", "Icon!")
            return
        }

        p := ConfigManager.GetActiveProfile()
        p.Keybind := val
        this.RefreshProfileDropdown()
        HotkeysManager.RegisterActivePreset()
        this.UpdateStatusBar()
    }

    static OnClearBind() {
        p := ConfigManager.GetActiveProfile()
        p.Keybind := ""
        this.HKTrigger.Value := ""
        this.RefreshProfileDropdown()
        HotkeysManager.RegisterActivePreset()
        this.UpdateStatusBar()
    }

    static OnClearGrid() {
        for idx, cb in this.GridCheckboxes {
            cb.Value := 0
        }
    }

    static OnResolutionChanged() {
        ConfigManager.SelectedResolution := this.DDLResolution.Text
    }

    static OnExitHotkeyChanged() {
        val := this.HKExit.Value
        if (StrLower(val) = "escape" || StrLower(val) = "esc") {
            this.HKExit.Value := ConfigManager.ExitHotkey
            MsgBox("Escape cannot be set as the Exit hotkey.", "Destiny 2 Swapper", "Icon!")
            return
        }
        ConfigManager.ExitHotkey := val
        HotkeysManager.RegisterExitHotkey()
    }

    static OnReloadHotkeyChanged() {
        val := this.HKReload.Value
        if (val = "")
            val := "F5"
        ConfigManager.ReloadHotkey := val
        HotkeysManager.RegisterReloadHotkey()
    }

    static OnReloadScript() {
        this.SaveUIToActiveProfile()
        ConfigManager.SelectedResolution := this.DDLResolution.Text

        valExit := this.HKExit.Value
        if (StrLower(valExit) != "escape" && StrLower(valExit) != "esc")
            ConfigManager.ExitHotkey := valExit

        valReload := this.HKReload.Value
        if (valReload != "")
            ConfigManager.ReloadHotkey := valReload

        ConfigManager.Save()
        Reload()
    }

    static OnSaveSettings() {
        this.SaveUIToActiveProfile()
        ConfigManager.SelectedResolution := this.DDLResolution.Text

        valExit := this.HKExit.Value
        if (StrLower(valExit) != "escape" && StrLower(valExit) != "esc")
            ConfigManager.ExitHotkey := valExit

        valReload := this.HKReload.Value
        if (valReload != "")
            ConfigManager.ReloadHotkey := valReload

        ConfigManager.Save()
        HotkeysManager.RegisterActivePreset()
        HotkeysManager.RegisterExitHotkey()
        HotkeysManager.RegisterReloadHotkey()

        this.RefreshProfileDropdown()
        this.UpdateStatusBar("Saved, all settings written to config.ini.")
    }

    static UpdateStatusBar(customMsg := "") {
        if (customMsg != "") {
            this.TextStatus.Text := customMsg
            SetTimer(() => this.UpdateStatusBar(), -3000)
            return
        }

        count := HotkeysManager.GetActiveListeningCount()
        this.TextStatus.Text := Format("Preset {} active ({} profile{} listening)", 
            ConfigManager.ActivePreset, count, count == 1 ? "" : "s")
    }
}

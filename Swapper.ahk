#Requires AutoHotkey v2.0

class Swapper {
    static IsSwapping := false
    static CancelRequested := false

    static Trigger(profile, *) {
        if this.IsSwapping
            return

        ; Only execute if Destiny 2 is the active window
        if !WinActive("ahk_exe destiny2.exe")
            return

        ; Safety check: ensure at least one loadout slot is enabled
        if (profile.LoadoutGrid.Length == 0) {
            ToolTip("Swap Aborted: No loadouts selected in Profile " profile.Name "!")
            SetTimer(() => ToolTip(), -2500)
            SoundPlay("*16")
            return
        }

        ; Sort loadouts in numerical ascending order
        sequence := profile.LoadoutGrid.Clone()
        this.SortAscending(sequence)

        this.IsSwapping := true
        this.CancelRequested := false

        try {
            this.RunLoop(profile, sequence)
        } finally {
            ToolTip()
            this.IsSwapping := false
        }
    }

    static RunLoop(profile, sequence) {
        resData := Coordinates.Get(ConfigManager.SelectedResolution)
        
        ; Normalize gear key (e.g. "Class Item" -> "ClassItem")
        gearKey := StrReplace(profile.SelectedGear, " ", "")
        if (!resData.Gear.Has(gearKey))
            gearKey := "Helmet"
        gearCoord := resData.Gear[gearKey]

        ; Tooltip placement below slot 20
        slot20 := resData.Loadouts[20]
        slot16 := resData.Loadouts[16]
        rowDelta := slot20.Y - slot16.Y
        ttX := slot20.X
        ttY := slot20.Y + Round(rowDelta * 0.65)

        currentSwaps := 0
        targetSwaps := profile.TargetSwaps
        ToolTip(currentSwaps "/" targetSwaps, ttX, ttY)

        ; 1: Move cursor to first slot in the ascending sequence
        firstSlot := sequence[1]
        firstCoord := resData.Loadouts[firstSlot]
        DllCall("SetCursorPos", "Int", firstCoord.X, "Int", firstCoord.Y)

        ; 2: Sample initial gear pixel color
        lastGearColor := PixelGetColor(gearCoord[1], gearCoord[2], "RGB")

        ; 3: Perform initial click
        this.ClickMouse()

        currentIndex := 1
        seqLen := sequence.Length

        ; Sub-interval tick callback for high-frequency pixel monitoring (~125 Hz)
        onTick() {
            if (this.CancelRequested)
                return true

            currentColor := PixelGetColor(gearCoord[1], gearCoord[2], "RGB")
            if (currentColor != lastGearColor) {
                currentSwaps++
                lastGearColor := currentColor
                ToolTip(currentSwaps "/" targetSwaps, ttX, ttY)

                if (currentSwaps >= targetSwaps)
                    return true ; Abort sleep immediately
            }
            return false
        }

        ; 4: Main swap loop
        while (!this.CancelRequested && currentSwaps < targetSwaps) {
            ; Advance to next slot in the sequence
            currentIndex := Mod(currentIndex, seqLen) + 1
            nextSlot := sequence[currentIndex]
            coord := resData.Loadouts[nextSlot]

            ; Move cursor to next slot
            DllCall("SetCursorPos", "Int", coord.X, "Int", coord.Y)

            ; Precise sleep with sub-interval pixel checking throughout the delay
            clickDelay := ConfigManager.ClampClickDelay(profile.ClickDelay)
            HighResTimer.Sleep(clickDelay, onTick)

            if (this.CancelRequested || currentSwaps >= targetSwaps)
                break

            ; Click slot
            this.ClickMouse()
        }

        ToolTip()
    }

    static Cancel() {
        if this.IsSwapping {
            this.CancelRequested := true
            ToolTip()
            this.IsSwapping := false
            ; Restart script minimized so it doesn't steal focus or pop up over Destiny 2
            Run('"' A_AhkPath '" "' A_ScriptFullPath '" /min')
            ExitApp()
        }
    }

    static ClickMouse() {
        DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0) ; Left Down
        DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0) ; Left Up
    }

    static SortAscending(arr) {
        n := arr.Length
        if (n <= 1)
            return

        loop n - 1 {
            i := A_Index
            loop n - i {
                j := A_Index
                if (arr[j] > arr[j + 1]) {
                    tmp := arr[j]
                    arr[j] := arr[j + 1]
                    arr[j + 1] := tmp
                }
            }
        }
    }
}

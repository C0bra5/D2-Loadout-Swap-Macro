#Requires AutoHotkey v2.0

class Coordinates {
    ; script constants
    static LOADOUT_DIMS := [4,5]
    static GEAR_SLOT_NAMES := ["Helmet", "Arms", "Chest", "Legs", "ClassItem"]
    static DEFAULT_RESOLUTION := "1920x1080"

    ; used to scale all other measurements
    static BASE_WIDTH := 2560.0
    static BASE_HEIGHT := 1440.0
    static BASE_GEAR_SLOT_SIZE := 128.0
    static BASE_LOADOUT_SLOT_SIZE := 118.0
    static BASE_LOADOUT_GRID_OFFSET := [98.0, 456.0]
    static BASE_GEAR_SLOTS_OFFSETS := [
        [1816, 292],
        [1816, 460],
        [1816, 628],
        [1816, 797],
        [1816, 964]
    ]
    static BASE_GEAR_CHECK_OFFSETS := [
        [66, 64],
        [86, 44],
        [66, 64],
        [77, 31],
        [66, 64]
    ]

    Width := Coordinates.BASE_WIDTH
    Height := Coordinates.BASE_HEIGHT
    Scale := 1.0
    XOffset := 0
    YGearOffset := 0
    YLoadoutOffset := 0
    Loadouts := Map()
    Gear := Map()

    __new(width, height) {
		ar := width / height
		br := 16 / 9
		if (br <= ar) {
			this.Height := height
			this.Width := Floor(this.Height / 9 * 16)
		}
		else {
			this.Width := width
			this.Height := Floor(this.Width / 16 * 9)
		}
        this.Scale := this.Width / Coordinates.BASE_WIDTH
        this.XOffset := Floor((width - this.Width) / 2)
		this.YGearOffset := Floor((height - this.Height) / 2)
		this.YLoadoutOffset := height - this.Height

        loadoutOffsets := [
            Floor(Coordinates.BASE_LOADOUT_GRID_OFFSET[1] * this.Scale),
            Floor(Coordinates.BASE_LOADOUT_GRID_OFFSET[2] * this.Scale)
        ]
        scaledGearSlot := Coordinates.BASE_GEAR_SLOT_SIZE * this.Scale
        loadoutClickOffset := Coordinates.BASE_LOADOUT_SLOT_SIZE * this.Scale / 2.0

        ; generate click locations for all loadout slots
        y := 0
        while (++y <= Coordinates.LOADOUT_DIMS[2]) {
            x := 0
            while (++x <= Coordinates.LOADOUT_DIMS[1]) {
                pos := {
                    X: Floor(this.XOffset + loadoutOffsets[1] + (x - 1) * scaledGearSlot + loadoutClickOffset),
                    Y: Floor(this.YLoadoutOffset + loadoutOffsets[2] + (y - 1) * scaledGearSlot + loadoutClickOffset)
                }
                idx := (y - 1) * Coordinates.LOADOUT_DIMS[1] + x
                this.Loadouts[idx] := pos
            }
        }

        ; generate loadout check locations
        for i,k in Coordinates.GEAR_SLOT_NAMES {
            this.Gear[k] := [
                Floor(this.XOffset
                    + (Coordinates.BASE_GEAR_SLOTS_OFFSETS[i][1] + Coordinates.BASE_GEAR_CHECK_OFFSETS[i][1]) * this.Scale),
                Floor(this.YGearOffset
                    + (Coordinates.BASE_GEAR_SLOTS_OFFSETS[i][2] + Coordinates.BASE_GEAR_CHECK_OFFSETS[i][2]) * this.Scale)
            ]
        }
    }

    Offset(x, y) {
        for _,v in this.Loadouts {
            v.X := v.X + x
            v.Y := v.Y + y
        }
        for _,v in this.Gear {
            v[1] := v[1] + x
            v[2] := v[2] + y
        }
    }

    static Get() {
        if (D2SWAPPER_OVERRIDE_RES) {
            return Coordinates(D2SWAPPER_RES_OVERRIDE[1], D2SWAPPER_RES_OVERRIDE[2])
        }
        MonitorGet(ConfigManager.SelectedMonitor, &left, &top, &right, &bottom)
        ret := Coordinates(right - left, bottom - top)
        ret.Offset(left, top)
        return ret
        
    }
}

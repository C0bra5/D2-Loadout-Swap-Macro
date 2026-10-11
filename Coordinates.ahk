#Requires AutoHotkey v2.0

class Coordinates {
    ; script constants
    static RESOLUTIONS := Map()
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
    

    static __New() {
        ; 2560x1440 (16:9)
        this.Register(2560, 1440, [156, 284, 412, 540], [514, 642, 770, 898, 1026],
            Map("Helmet", [1882, 356], "Arms", [1902, 504], "Chest", [1882, 692], "Legs", [1893, 828], "ClassItem", [1882, 1028]))

        ; 1600x1200 (4:3)
        this.Register(1600, 1200, [97, 177, 257, 337], [622, 702, 782, 862, 942],
            Map("Helmet", [1172, 266], "Arms", [1184, 394], "Chest", [1172, 546], "Legs", [1179, 666], "ClassItem", [1172, 826]))

        ; 2560x1080 (21:9)
        this.Register(2560, 1080, [435, 531, 627, 723], [385, 481, 577, 673, 769],
            Map("Helmet", [1728, 267], "Arms", [1743, 378], "Chest", [1728, 519], "Legs", [1737, 621], "ClassItem", [1728, 771]))

        ; 2304x1440 (16:10)
        this.Register(2304, 1440, [141, 256, 371, 486], [607, 722, 837, 952, 1067],
            Map("Helmet", [1693, 393], "Arms", [1712, 525], "Chest", [1693, 695], "Legs", [1703, 817], "ClassItem", [1693, 997]))

        ; 2048x1280 (16:10)
        this.Register(2048, 1280, [125, 227, 329, 431], [539, 641, 743, 845, 947],
            Map("Helmet", [1504, 348], "Arms", [1520, 466], "Chest", [1504, 616], "Legs", [1513, 724], "ClassItem", [1504, 884]))

        ; 1920x1440 (4:3)
        this.Register(1920, 1440, [117, 213, 309, 405], [745, 841, 937, 1033, 1129],
            Map("Helmet", [1400, 440], "Arms", [1411, 554], "Chest", [1400, 700], "Legs", [1405, 796], "ClassItem", [1400, 950]))

        ; 1920x1200 (16:10)
        this.Register(1920, 1200, [117, 213, 309, 405], [505, 601, 697, 793, 889],
            Map("Helmet", [1412, 326], "Arms", [1427, 437], "Chest", [1412, 578], "Legs", [1420, 680], "ClassItem", [1412, 830]))

        ; 1920x1080 (16:9)
        this.Register(1920, 1080, [117, 213, 309, 405], [385, 481, 577, 673, 769],
            Map("Helmet", [1406, 267], "Arms", [1421, 378], "Chest", [1406, 519], "Legs", [1415, 621], "ClassItem", [1406, 771]))

        ; 1680x1050 (16:10)
        this.Register(1680, 1050, [103, 187, 271, 355], [441, 525, 609, 693, 777],
            Map("Helmet", [1232, 285], "Arms", [1245, 382], "Chest", [1232, 505], "Legs", [1240, 594], "ClassItem", [1232, 725]))

        ; 1600x1024 (25:16)
        this.Register(1600, 1024, [97, 177, 257, 337], [445, 525, 605, 685, 765],
            Map("Helmet", [1175, 282], "Arms", [1188, 374], "Chest", [1175, 492], "Legs", [1182, 577], "ClassItem", [1175, 702]))

        ; 1600x900 (16:9)
        this.Register(1600, 900, [97, 177, 257, 337], [321, 401, 481, 561, 641],
            Map("Helmet", [1172, 222], "Arms", [1184, 315], "Chest", [1172, 432], "Legs", [1179, 517], "ClassItem", [1172, 642]))

        ; 1440x1080 (4:3)
        this.Register(1440, 1080, [87, 159, 231, 303], [559, 631, 703, 775, 847],
            Map("Helmet", [1055, 239], "Arms", [1067, 353], "Chest", [1055, 491], "Legs", [1061, 599], "ClassItem", [1055, 743]))

        ; 1440x900 (16:10)
        this.Register(1440, 900, [87, 159, 231, 303], [379, 451, 523, 595, 667],
            Map("Helmet", [1054, 246], "Arms", [1065, 328], "Chest", [1054, 434], "Legs", [1060, 509], "ClassItem", [1054, 622]))

        ; 1366x768 (16:9)
        this.Register(1366, 768, [84, 152, 220, 288], [275, 343, 411, 479, 547],
            Map("Helmet", [1000, 190], "Arms", [1011, 269], "Chest", [1000, 370], "Legs", [1006, 443], "ClassItem", [1000, 550]))

        ; 1280x1440 (8:9)
        this.Register(1280, 1440, [106, 234, 362, 490], [514, 642, 770, 898, 1026],
            Map("Helmet", [936, 356], "Arms", [946, 504], "Chest", [936, 692], "Legs", [942, 828], "ClassItem", [936, 1028]))

        ; 1280x1024 (5:4)
        this.Register(1280, 1024, [76, 140, 204, 268], [561, 625, 689, 753, 817],
            Map("Helmet", [935, 225], "Arms", [945, 334], "Chest", [935, 463], "Legs", [941, 566], "ClassItem", [935, 701]))

        ; 1280x960 (4:3)
        this.Register(1280, 960, [76, 140, 204, 268], [498, 562, 626, 690, 754],
            Map("Helmet", [938, 214], "Arms", [948, 316], "Chest", [938, 438], "Legs", [943, 534], "ClassItem", [938, 662]))

        ; 1280x800 (16:10)
        this.Register(1280, 800, [76, 140, 204, 268], [338, 402, 466, 530, 594],
            Map("Helmet", [936, 218], "Arms", [946, 292], "Chest", [936, 386], "Legs", [942, 454], "ClassItem", [936, 554]))

        ; 1280x768 (5:3)
        this.Register(1280, 768, [76, 140, 204, 268], [305, 369, 433, 497, 561],
            Map("Helmet", [938, 201], "Arms", [948, 275], "Chest", [938, 369], "Legs", [944, 437], "ClassItem", [938, 537]))

        ; 1280x720 (16:9)
        this.Register(1280, 720, [76, 140, 204, 268], [258, 322, 386, 450, 514],
            Map("Helmet", [936, 178], "Arms", [946, 252], "Chest", [936, 346], "Legs", [942, 414], "ClassItem", [936, 514]))

        ; 3840x2160 (16:9)
        this.Register(3840, 2160, [233, 425, 617, 809], [771, 963, 1155, 1347, 1539],
            Map("Helmet", [2806, 534], "Arms", [2837, 755], "Chest", [2806, 1038], "Legs", [2823, 1242], "ClassItem", [2806, 1542]))

        ; 2560x1600 (16:10)
        this.Register(2560, 1600, [155, 283, 411, 539], [675, 803, 931, 1059, 1187],
            Map("Helmet", [1868, 436], "Arms", [1888, 584], "Chest", [1868, 772], "Legs", [1880, 908], "ClassItem", [1868, 1108]))

        ; 1360x768 (16:9)
        this.Register(1360, 768, [82, 150, 218, 286], [276, 344, 412, 480, 548],
            Map("Helmet", [996, 190], "Arms", [1007, 268], "Chest", [996, 368], "Legs", [1002, 440], "ClassItem", [996, 546]))

        ; 1280x1080 (32:27)
        this.Register(1280, 1080, [76, 140, 204, 268], [618, 682, 746, 810, 874],
            Map("Helmet", [940, 232], "Arms", [950, 348], "Chest", [940, 484], "Legs", [946, 594], "ClassItem", [940, 736]))

        ; 3440x1440 (21:9)
        this.Register(3440, 1440, [595, 723, 851, 979], [514, 642, 770, 898, 1026],
            Map("Helmet", [2318, 356], "Arms", [2338, 504], "Chest", [2318, 692], "Legs", [2318, 828], "ClassItem", [2428, 1028]))

        ; 1920x720
        this.Register(1920, 720, [397, 461, 525, 589], [258, 322, 386, 450, 514],
            Map("Helmet", [1258, 178], "Arms", [1269, 251], "Chest", [1258, 346], "Legs", [1264, 414], "ClassItem", [1258, 514]))
        
    }

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

    static Register(width, height, cols, rows, gearMap) {
        loadouts := Map()
        for r, y in rows {
            for c, x in cols {
                idx := (r - 1) * cols.Length + c
                loadouts[idx] := { X: x, Y: y }
            }
        }
        Coordinates.RESOLUTIONS[width "x" height] := {
            Loadouts: loadouts,
            Gear: gearMap,
            Cols: cols,
            Rows: rows
        }

        mapping := Coordinates(width, height)
        Coordinates.RESOLUTIONS[width "x" height] := mapping
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

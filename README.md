This is the only macro allowed for swapping loadouts for the Perk Overload Glitch (POG) or and all other Universal Cannon Glitches (UCG). This macro was created by [redfish18](https://www.speedrun.com/users/redfish18), but we host our own version for safety reasons.

Our mirror can be found on [Github](https://github.com/C0bra5/POG-swaps-macro) and Latest releases can be found [here](https://github.com/C0bra5/POG-swaps-macro/releases/latest).

# Configuration & Usage Guide

## Requirements
AHKv2: https://www.autohotkey.com/download/

---

## Quick Start: Setting Up Your First Profile

1. **Set Game Resolution** - Choose your current game resolution so coordinate detection aligns properly.
2. **Bind Trigger Hotkey** - Click inside the **Trigger Hotkey** input, press your preferred activation key, then click **Save Settings** to confirm and release field focus.
3. **Configure Click Delay** - Enter the interval in milliseconds between loadout clicks.
   - **Note:** _150 ms is the minimum delay allowed_, you cannot set it any lower. Modifying the macro to use a lower value is not allowed and will be grounds for rejection. If you want to go faster, you'll have to perform your swaps by hand.
4. **Set Target Swaps** - Specify how many confirmed swaps the macro should execute before automatically stopping.
5. **Select Gear Slot** - Pick the armor slot the macro polls to verify successful swaps.
   - **Important:** Your alternating loadouts must have visually distinct armor ornaments on this slot that correlate with perk status:
   - **Loadout A:** Perk equipped (e.g., *Envious Arsenal*) + **Ornament A**
   - **Loadout B:** No perk + **Ornament B**
6. **Select Loadout Grid Slots** - Choose the loadout slots included in the rotation. Execution always runs in ascending order (left to right, top to bottom).

---

## Core Concepts

### Profiles
Profiles let you configure multiple swap sequences within the same macro.

- **Concurrent Hotkeys:** Profiles can run side-by-side if bound to different hotkeys (e.g., **F9** triggers 80 swaps; **F10** triggers 160 swaps).
- **Independent Settings:** Every profile maintains its own click delay, swap count, monitored slot, and slot order.
- **Profile Management:** Use **New** to create a profile within the active preset, or **Delete** to remove the active profile.

### Presets
Presets switch your entire hotkey and profile configuration between different contexts (such as different characters).

- **Keybind Recycling:** Reuse identical keybinds for different slot layouts.
- **Example:**
  - **Preset A (Character 1):** **F9** triggers slots **1, 2, 3, 4**.
  - **Preset B (Character 2):** **F9** triggers slots **17, 18, 19, 20**.
- **Switching:** Select a preset from the top and click **Save Settings**.

---

## Global Settings
- **Reload Script**:  Halts current actions to interrupt the script while keeping it open.
- **Exit Script**: Instantly forces the macro to close.
- **Game Resolution**: Selects coordinate sets for UI clicks and pixel checks.

---

## Extra Notes

Escape key cannot be used as a hotkey. It serves as a permanent and second way to stop a swap sequence early.

Gear check coordinates for 4:3 resolutions may be incorrect.

Your game must be on your main monitor in the same resolution as the monitor since pixel colour checking does not work well when an application's resolution is not the same as that of the monitor it is displayed on.
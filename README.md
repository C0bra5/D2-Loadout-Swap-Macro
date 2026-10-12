This is the only macro allowed for swapping loadouts in runs submitted to Destiny 2's Speedrun.com leaderboards. This macro was created for the Perk Overload Glitch (POG) and all other Universal Cannon Glitches (UCG) that require extensive loadout swapping. [Redfish18](https://github.com/Redfish18/POG-swaps-macro) created this macro, but we host and maintain our own version for safety reasons.

Our mirror is on [GitHub](https://github.com/C0bra5/D2-Loadout-Swap-Macro), and the latest releases are [here](https://github.com/C0bra5/D2-Loadout-Swap-Macro/releases/latest).

# Configuration & Usage Guide

## Requirement
- AutoHotkey V2.0: https://www.autohotkey.com
  - Only needed if you are editing or running the script directly instead of using the executables we release.

---

## Quick Start: Setting Up Your First Profile

1. **Select Your Monitor** - Select the monitor you use to play the game.
    - The game must be in full-screen mode, or else the macro won't work.
2. **Bind Trigger Hotkey** - Click inside the **Trigger Hotkey** input, press your preferred activation key, then click **Save Settings** to confirm and release field focus.
3. **Configure Click Delay** - Enter the interval in milliseconds between loadout clicks.
    - **150 ms is the minimum delay allowed for Speedrun.com submission.**,  _Modifying this macro to use a lower value is not allowed and will be grounds for run rejection._
    - Due to a quirk in how D2 handles the swap requests, using a value below 180ms will considerably slow down the swaps when using 2-slot configurations.
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
- **Monitor**: Selects the monitor you play the game on.

---

## Extra Notes

- The Escape key cannot be used as a hotkey. It serves as a permanent second way to stop a swap sequence early.
- Your game must be in full screen for this macro to work.

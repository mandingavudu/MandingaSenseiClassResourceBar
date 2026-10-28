# 🌀 **MandingaSenseiClassResourceBar**

[![GitHub Release](https://img.shields.io/github/v/release/mandingavudu/MandingaSenseiClassResourceBar?style=for-the-badge)](https://github.com/mandingavudu/MandingaSenseiClassResourceBar/releases/latest) ![CurseForge Game Versions](https://img.shields.io/curseforge/game-versions/1770529?style=for-the-badge&logo=battledotnet) [![CurseForge Downloads](https://img.shields.io/curseforge/dt/1770529?style=for-the-badge&logo=curseforge&label=Downloads)](https://www.curseforge.com/projects/1770529)

**MandingaSenseiClassResourceBar** is a lightweight, fully customizable resource display addon for World of Warcraft.
It automatically adapts to your character’s **class, specialization, and shapeshift form**, showing your **primary** and **secondary** resources in clean, modern bars that you can freely move, resize, and restyle through **Edit Mode**.

***

## ✨ Features

***

## 🎯 Dynamic Resource Tracking

Automatically detects your character’s current resource type:

**Health Bar**

**Primary Resources Supported**  
Mana, Rage, Energy, Focus, Fury, Runic Power, Astral Power, Maelstrom Weapon and more.

**Secondary Resources Supported**

*   **Paladin** → Holy Power
*   **Rogue** → Combo Points
*   **Monk** → Chi / **Stagger** (Brewmaster)
*   **Warlock** → Soul Shards (shows partial resource)
*   **Death Knight** → Runes (with cooldown timers per rune)
*   **Evoker** → Essence
*   **Mage** → Arcane Charges
*   **Druid** → Combo Points (Cat Form)
*   **Demon Hunter** → Soul Fragments (Devourer, Vengeance)
*   **Hunter** → Tip of the Spear (Survival)
*   **Warrior** → Whirlwind (Fury)

**Tertiary Resources Supported**

*   **Evoker** → Ebon Might
*   **Death Knight (Blood)** → Bone Shield stacks, white by default, with configurable stack dividers. Maximum 10, or 12 with Improved Bone Shield. Uses combat-safe aura bindings and standard text formats; no aura shows no text.
*   **Demon Hunter (Devourer)** → Soul Fragments on the ground (10-soul scale; absorbed souls remain on the secondary bar).

Devourer’s tertiary bar uses Blizzard aura bindings for combat-safe fill and stack text. It uses a continuous fill with a white 4/10 threshold marker and supports independent Edit Mode positioning, styling, visibility, and ground-soul color (default: `#071c62`). Text follows the standard resource-number format, precision, and visibility settings, including percentages and combined formats. With no aura, the bar is empty and shows no text. Active counts have no text background and render above the threshold marker. Moment of Craving replaces the marker with a steady white outline with a 1 px margin. During combat, this uses the Reap/Cull spell-overlay signal; the proc behavior has been verified in game. Counts above 10 remain visible as text while the fill caps at 10. Appearance changes during aura restrictions apply once restrictions end. This bar requires the client’s `CustomAuraContainer` application-bar/count APIs; its fill is engine-driven rather than using the addon’s smoothing.

**Druid Form Adaptive Support:**  
Automatically switches to Mana, Energy, Rage, or Astral Power depending on current shapeshift form.

***

## 🧩 Edit Mode Integration

Built on **LibEQOL**, offering seamless integration with Blizzard’s modern UI:

*   Move and reposition bars anywhere on your screen
*   Resize and restyle without extra menus
*   Every setting is **per-layout**, meaning different UI layouts can have unique bar setups

***

## ⚙️ Customization Options

Each bar (Primary & Secondary) has its own configuration:

### **Appearance & Layout**

*   📏 Adjustable **width**, **height**, and **overall scale**
*   ✏️ Customizable **font**, **size**, and **outline**
*   🖼 Multiple **bar textures**, **backgrounds**, and **border styles**
*   🎯 Text alignment (Left / Center / Right), Font, Size
*   🎨 All the resources color are editable
*   ⭐ Support for LibSharedMedia-3.0

### **Behavior**

*   💬 Toggle resource number text
*   🔄 Optional **smooth animation** for bar updating
*   🕶 Visibility rules:
    *   Always visible
    *   In combat
    *   With target
    *   Target OR combat
    *   Hidden
*   ✔️ Tick marks for segmented resources (Combo Points, Chi, Holy Power, Essence, etc.)
*   💧 Optional **Mana as percentage**
*   ⏱ Rune-specific cooldown text for Death Knights

### **Hide default Blizzard UI**

*   Option to hide Blizzard Player Frame
*   Option to hide Blizzard secondary resource bars (Combo Points, Essence, Holy Power, Arcane Charges, etc.)

### **Advanced**

*   🔗 Width syncing with the Cooldown Manager :
    *   Essential Cooldowns
    *   Utility Cooldowns

***

## 🔧 Performance

*   Lightweight and efficient
*   Event-driven updates (no constant polling)
*   Minimal CPU usage
*   No overhead when the bar is hidden or disabled
*   Uses clean Blizzard-style textures for a cohesive UI look

Install the addon in `Interface/AddOns/MandingaSenseiClassResourceBar`. The TOC, XML loader, main Lua file, and settings Lua file use the `MandingaSenseiClassResourceBar` prefix. Settings load from `MandingaSenseiClassResourceBarDB`, falling back to a copy of `SenseiClassResourceBarDB` when no valid new database exists. If both exist, the new database wins without merging; only `MandingaSenseiClassResourceBarDB` is saved by this addon. This accepts legacy settings without maintaining two saved copies.

To migrate, exit WoW, back up the account SavedVariables files, and copy `WTF/Account/<account>/SavedVariables/SenseiClassResourceBar.lua` to `MandingaSenseiClassResourceBar.lua` in the same directory. Leave the variable name inside the copied file unchanged; it migrates on load. Disable the original addon. Merely supporting both variable names does not load the original addon’s separate file. To move settings back to the original addon, copy the file to its original filename and rename the variable inside to `SenseiClassResourceBarDB` while WoW is closed.

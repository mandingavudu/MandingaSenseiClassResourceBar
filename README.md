# 🌀 **MandingaSenseiClassResourceBar**

**MandingaSenseiClassResourceBar** is a lightweight, fully customizable resource display addon for World of Warcraft. It is a fork of [SenseiClassResourceBar](https://github.com/Snsei987/SenseiClassResourceBar), with extended functionality mostly derived from my own or my friends' needs/preferences.
It automatically adapts to your character’s **class, specialization, and shapeshift form**, showing your **primary**, **secondary**, and **tertiary**<sup>1</sup> resources in clean, modern bars that you can freely move, resize, and restyle through **Edit Mode**.

***

## ✨ Features

### 🎯 Dynamic Resource Tracking

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
*   **Demon Hunter** → Soul Fragments (Devourer, Vengeance). Devourer’s secondary bar has a maximum of 40 with a white divider at 30 during Void Metamorphosis; otherwise 50, or 35 with Soul Glutton.
*   **Hunter** → Tip of the Spear (Survival)
*   **Warrior** → Whirlwind (Fury)

**Tertiary Resources Supported**

*   **Evoker (Augmentation)** → Ebon Might
*   **Paladin (Protection)** → Shield of the Righteous remaining duration on a fixed 13.5-second scale. Purple (`#6936af`) by default, dividers at 4.5 and 9 seconds, standard text formats and precision; empty with no text when absent. Duration text uses the standard resource text renderer; Current / Maximum displays remaining seconds / 13.5. As with other aura resources, percentage text is unavailable when the remaining value is restricted. A steady gold outline appears while the player has the defensive Consecration buff (188370), both in and out of combat, and disappears when absent. In combat, track the defensive buff in a visible Cooldown Manager Buff Icon or Buff Bar viewer; the ground-effect/totem entry does not count. Extensions refill the bar; durations over 13.5 seconds cap the fill while retaining the actual text value.
*   **Death Knight (Unholy)** → Lesser Ghoul buff stacks consumed by Scourge Strike, with an 8-stack scale and configurable dividers. Default color `#1e65a1` (`0.118, 0.396, 0.631`). Uses the shared combat-safe aura bindings and standard text formats; stack counts remain integers and no aura shows no text. A steady white outline (`1.000, 1.000, 1.000`) appears while the 25-second Festering Scythe buff (1241077) is active, including outside combat. For combat tracking, keep its buff in a visible Cooldown Manager Buff Icon or Buff Bar viewer.
*   **Death Knight (Blood)** → Bone Shield stacks, white by default, with configurable stack dividers; the divider after stack 5 uses the default Blood rune red. Maximum 10, or 12 with Improved Bone Shield. Uses combat-safe aura bindings and standard text formats; no aura shows no text. A steady red outline (`#FF0000`, RGB `1.000, 0.000, 0.000`) appears only with the Sanguine Ground talent selected and the Death and Decay player buff (188290) active, both in and out of combat. Track the Death and Decay buff in a visible Cooldown Manager Buff Icon or Buff Bar viewer for combat detection. Without the talent or buff, the outline is hidden.
*   **Demon Hunter (Devourer)** → Soul Fragments on the ground (10-soul scale; absorbed souls remain on the secondary bar).

All four complementary tertiary-bar outlines have independent color and opacity settings under their respective class sections in the addon settings: Moment of Craving, Sanguine Ground, Consecration, and Festering Scythe. The colors described here are the defaults. These overrides are included when exporting power colors and support resetting to their defaults. Sanguine Ground, Consecration, and Festering Scythe each have a checkbox beside their color picker to enable or disable the glow. All three are enabled by default; disabling hides the outline immediately and disables its picker while retaining its color.

Bone Shield, Lesser Ghouls, and ground Soul Fragments share the `AuraStackBar` helper for aura-bound stack rendering, with separate resource-specific indicators.

Blizzard Cooldown Manager must be enabled: SotR requires a visible Tracked Bar; the Sanguine Ground outline accepts a visible Buff Icon or Buff Bar viewer. Without that tracking, SotR is empty and the Sanguine Ground outline is disabled; the addon reports the missing setup once per session. SotR tracking accepts the cast spell or buff entry and reads remaining seconds directly from Blizzard’s tracked bar, without re-querying restricted aura instances or constructing timers from secret fields. Bone Shield’s stack bar itself remains independent of Cooldown Manager.

For tertiary bars, Text Settings Precision is available for every resource while Show Resource Number is enabled. Duration values (e.g. Shield of the Righteous and Ebon Might) honor it; select `12.3` for one decimal place. Stack counts (e.g. Bone Shield and Souls) ignore it and remain integers. Percentage formats retain their configured precision.

Devourer’s tertiary bar uses Blizzard aura bindings for combat-safe fill and stack text. It uses a continuous fill with a white 4/10 threshold marker and supports independent Edit Mode positioning, styling, visibility, and ground-soul color (default: `#071c62`). Text follows the standard resource-number format, precision, and visibility settings, including percentages and combined formats. With no aura, the bar is empty and shows no text. Active counts have no text background and render above the threshold marker. Moment of Craving replaces the marker with a steady white outline with a 1 px margin. During combat, this uses the Reap/Cull spell-overlay signal; the proc behavior has been verified in game. Counts above 10 remain visible as text while the fill caps at 10. Appearance changes during aura restrictions apply once restrictions end. This bar requires the client’s `CustomAuraContainer` application-bar/count APIs; its fill is engine-driven rather than using the addon’s smoothing.

Due to how some of the tertiary bars had to be setup, at least some of them are not able to show any duration/stack count value when the aura they represent is not present.

**Druid Form Adaptive Support:**  
Automatically switches to Mana, Energy, Rage, or Astral Power depending on current shapeshift form.

***

### 🧩 Edit Mode Integration

Built on **LibEQOL**, offering seamless integration with Blizzard’s modern UI:

*   Move and reposition bars anywhere on your screen
*   Resize and restyle without extra menus
*   Every setting is **per-layout**, meaning different UI layouts can have unique bar setups

***

### ⚙️ Customization Options

Each bar (Primary & Secondary) has its own configuration:

#### **Appearance & Layout**

*   📏 Adjustable **width**, **height**, and **overall scale**
*   ✏️ Customizable **font**, **size**, and **outline**
*   🖼 Multiple **bar textures**, **backgrounds**, and **border styles**
*   🎯 Text alignment (Left / Center / Right), Font, Size
*   🎨 All the resources color are editable
*   Color settings are ordered by **General Colors** (Health first, followed by resources shared across classes), then one section per class. Class sections list shared settings first, followed by specialization order and primary, secondary, then tertiary resources. Spec-specific entries start with the localized specialization name; outline colors are labeled Glow. Color swatches sit to the right of the labels with extra spacing to prevent overlap.
*   ⭐ Support for LibSharedMedia-3.0

#### **Behavior**

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

#### **Hide default Blizzard UI**

*   Option to hide Blizzard Player Frame
*   Option to hide Blizzard secondary resource bars (Combo Points, Essence, Holy Power, Arcane Charges, etc.)

#### **Advanced**

*   🔗 Width syncing with the Cooldown Manager :
    *   Essential Cooldowns
    *   Utility Cooldowns

***

### 🔧 Performance

*   Lightweight and efficient
*   Event-driven updates (no constant polling)<sup>2</sup>
*   Minimal CPU usage<sup>2</sup>
*   No overhead when the bar is hidden or disabled
*   Uses clean Blizzard-style textures for a cohesive UI look

***

## Migrating from the original SenseiClassResourceBar

To migrate, exit WoW, back up the account SavedVariables files, and copy `WTF/Account/<account>/SavedVariables/SenseiClassResourceBar.lua` to `MandingaSenseiClassResourceBar.lua` in the same directory. Leave the variable name inside the copied file unchanged; it migrates on load. Disable the original addon. Merely supporting both variable names does not load the original addon’s separate file. To move settings back to the original addon, copy the file to its original filename and rename the variable inside to `SenseiClassResourceBarDB` while WoW is closed.

***

## Notes
1. You may find that the chosen tertiary resources seem to be arbitrary. Once again, this fork was made to adapt to my own gameplay.
2. Some buffs require different approaches to be tracked, and while I do believe those should perform adequately as well, I haven't exactly benchmarked it.
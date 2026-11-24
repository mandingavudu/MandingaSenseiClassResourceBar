# 🌀 **MandingaSenseiClassResourceBar**

**MandingaSenseiClassResourceBar** is a lightweight, fully customizable resource display addon for World of Warcraft. It is a fork of [SenseiClassResourceBar](https://github.com/Snsei987/SenseiClassResourceBar), with extended functionality mostly derived from my own or my friends' needs/preferences.
It automatically adapts to your character’s **class, specialization, and shapeshift form**, showing your **primary**, **secondary**, **tertiary**<sup>1</sup>, and **quaternary** resources in clean, modern bars that you can freely move, resize, and restyle through **Edit Mode**.

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

All tertiary and quaternary resources have an enable checkbox beside their existing color entry in the class settings. They are enabled by default. Disabling a bar removes it from gameplay and Edit Mode while retaining its settings; Voidfall’s toggle applies to both Annihilator specs.

**Tertiary Resources Supported**

*   **Rogue (Outlaw)** → Roll the Bones. Four segments show the active buff's rank, from One of a Kind to Jackpot. A gold glow appears at ranks 3 and 4 while Keep It Rolling is ready to cast. In Rogue color settings, you can change the bar's default red (`#E60000`), change the glow color, or turn the glow off. Uses Edit Mode for layout and tracks auras without CDM.

*   **Evoker (Augmentation)** → Ebon Might
*   **Paladin (Protection)** → Shield of the Righteous duration, with a Consecration glow
*   **Death Knight (Unholy)** → Lesser Ghouls, with a Festering Scythe glow
*   **Death Knight (Blood)** → Bone Shield, with a Sanguine Ground glow
*   **Demon Hunter (Devourer)** → Ground Soul Fragments, with a Moment of Craving glow

See [Cooldown Manager requirements](#cooldown-manager-cdm-requirements-for-combat-tracking) for required aura tracking.

See [Text setting overrides](#text-setting-overrides) for how aura bars display stacks, durations, and percentages.

All tertiary glows have configurable colors and opacity. Roll the Bones, Sanguine Ground, Consecration, and Festering Scythe glows can also be toggled independently.

**Quaternary Resources Supported**

*   **Rogue (Trickster)** → Coup de Grace (Escalating Blade): integer stacks up to 4, with dividers and a configurable color. Available to Outlaw and Subtlety with Coup de Grace selected; no CDM tracking required.
*   **Demon Hunter (Annihilator — Devourer or Vengeance)** → Voidfall, capped at 3 stacks and available only with Annihilator selected. Tracks the building and ready auras; the ready aura keeps the bar at 3 with a full-stack glow. Includes regular configurable stack dividers at 1/3 and 2/3, plus an additional white-by-default Void Ray threshold marker at 2/3 for Devourer only. Bar, marker, and glow colors are configurable. The Void Ray (Threshold) marker has its own enable checkbox; color swatches remain usable while disabled. Uses tertiary-style Edit Mode settings and integer text; absent auras show no text. Aura bindings handle combat tracking without CDM.

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
*   🎨 All the resources color are editable; color swatches remain usable when their bar or glow is disabled.
*   Color settings are ordered by **General Colors** (Health first, followed by resources shared across classes), then one section per class. Class sections list shared settings first, followed by specialization order and primary, secondary, then tertiary resources. Spec-specific entries start with the localized specialization name. Hero-talent settings follow all spec-specific entries and start with the hero talent name (e.g. Annihilator); outline colors are labeled Glow. Color swatches sit to the right of the labels with extra spacing to prevent overlap.
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

### Text setting overrides

Most bars use the selected **Format** when **Show Resource Number** is enabled. Standard current and maximum values use Blizzard's number abbreviation. The **Precision** control is enabled for percentage formats on health, primary, and secondary bars. On tertiary and quaternary bars, it is enabled whenever resource numbers are shown.

| Resource / option | Text behavior |
| --- | --- |
| **Mana — Show Mana As Percent** | On the primary or secondary bar, displays only the percentage. Choose `Percent%` to include a `%` suffix. |
| **Bone Shield, Lesser Ghouls, ground Soul Fragments, Coup de Grace** | Stack counts are integers. Percentages honor precision. Text is blank while the aura is absent. |
| **Roll the Bones** | Ranks display as integers from 1 to 4. Percentages honor precision. Text is blank while the aura is absent. |
| **Voidfall** | Shows `1/3`, `2/3`, or `3/3` whenever resource text is enabled, regardless of the selected format or precision. The ready aura shows `3/3`. Text is blank when both auras are absent. |
| **Shield of the Righteous** | Current text is remaining seconds at the selected precision, with a 13.5-second maximum. Text is blank without the aura or required tracking. The percentage number is blank when Blizzard restricts the duration value. |
| **Ebon Might** | Current text is remaining seconds at the selected precision, with a 20-second maximum. The current value is zero while the aura is absent. |
| **Brewmaster Stagger** | The percentage is the staggered amount divided by maximum health. When the staggered amount is restricted, the formatter uses the last cached percentage. This fallback needs a prior readable update. |
| **Vengeance Soul Fragments** | The percentage number is always blank. Current and maximum values remain available. |
| **Enhancement Maelstrom Weapon** | Maximum and percentage text use the full 10-stack capacity, twice the base fill scale. |
| **Destruction Soul Shards** | Current and maximum text convert internal fragment values into shard units. |
| **Other custom resources using the shared formatter** | The percentage number is blank when Blizzard restricts the current or maximum value, or when the maximum is zero. |
| **Rune / Essence segment timers** | Recharging segments display remaining seconds. **Show Resource Charge Timer** and **Charge Timer Precision** control this text independently of the main resource number. |
| **Edit Mode preview** | A bar with no resource for the current specialization can display the sample value `4`. |

When the percentage number is blank, the separator and `%` suffix in the selected format can still appear.

#### **Hide default Blizzard UI**

*   Option to hide Blizzard Player Frame
*   Option to hide Blizzard secondary resource bars (Combo Points, Essence, Holy Power, Arcane Charges, etc.)

#### **Advanced**

*   🔗 **Width Mode** can use the shown **Essential Cooldowns**, **Utility Cooldowns**, or **Tracked Buffs** viewer's width when the layout is applied. It uses the configured width if the selected viewer is hidden or unavailable.
*   **Relative Frame** can anchor a bar to any of those three viewers. If the selected viewer is unavailable, the bar anchors to `UIParent`.

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
2. Some buff trackers use periodic updates or Blizzard aura bindings rather than events alone.

### Cooldown Manager (CDM) requirements for combat tracking

When Blizzard restricts direct aura reads, including in combat, these features get their aura data from Cooldown Manager. Enable it and keep the corresponding viewer shown. Outside those restrictions, the addon reads the player aura directly.

| Bar or glow | Aura to track in CDM | Required tracking type |
| --- | --- | --- |
| Protection Paladin — Shield of the Righteous duration bar and text | **Shield of the Righteous** (player buff 132403 or cast 53600) | **Tracked Bar only**, which supplies the remaining duration |
| Protection Paladin — Consecration glow | **Consecration**, the defensive player buff (188370) | **Tracked Bar or Tracked Buff icon** |
| Blood Death Knight — Sanguine Ground glow | **Death and Decay**, the player buff (188290), with Sanguine Ground selected | **Tracked Bar or Tracked Buff icon** |
| Unholy Death Knight — Festering Scythe glow | **Festering Scythe**, the 25-second buff (1241077) | **Tracked Bar or Tracked Buff icon** |

The three glows in the table also need to be enabled in the addon's class settings.

**Bone Shield**, **Lesser Ghouls**, **ground Soul Fragments**, **Roll the Bones**, **Coup de Grace**, and **Voidfall** use Blizzard's aura bindings independently of Cooldown Manager. The **Moment of Craving** glow uses the spell-overlay signal in combat, **Roll the Bones** checks the cooldown of Keep It Rolling directly, and **Ebon Might** reads its duration directly from the player aura.

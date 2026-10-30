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

*   **Evoker (Augmentation)** → Ebon Might
*   **Paladin (Protection)** → Shield of the Righteous duration, with a Consecration glow
*   **Death Knight (Unholy)** → Lesser Ghouls, with a Festering Scythe glow
*   **Death Knight (Blood)** → Bone Shield, with a Sanguine Ground glow
*   **Demon Hunter (Devourer)** → Ground Soul Fragments, with a Moment of Craving glow

See [Cooldown Manager requirements](#cooldown-manager-cdm-requirements-for-combat-tracking) for required aura tracking.

Some tertiary bars show no text when their aura is absent because Blizzard’s aura-bound displays provide no value. Duration text honors the precision setting; stack counts remain integers.

All tertiary glows have configurable colors and opacity. Sanguine Ground, Consecration, and Festering Scythe can also be toggled independently.

**Quaternary Resources Supported**

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

Most bars follow the selected text format and visibility. These exceptions and resource-specific rules apply:

| Resource / option | Text behavior |
| --- | --- |
| **Mana — Show Mana as Percentage** | Overrides the selected format with percentage-only text. The `%` suffix appears when the selected format is `Percent%`. |
| **Bone Shield, Lesser Ghouls, ground Soul Fragments, Voidfall** | Stack counts remain integers regardless of precision; percentages honor precision. No aura means no text. |
| **Shield of the Righteous / Ebon Might** | Current values are seconds with the selected precision. SotR uses 13.5 seconds as its displayed maximum and shows no text without its aura or required tracking. |
| **Vengeance Soul Fragments** | The percentage component is blank; current/maximum components remain available. |
| **Enhancement Maelstrom Weapon** | Maximum and percentage text use the full stack capacity, twice the base fill scale. |
| **Destruction Soul Shards** | Current and maximum text convert internal fragment values into shard units. |
| **Other aura resources with restricted values** | Percentage text is blank when the addon cannot calculate it; aura-bound stack bars and Stagger use their dedicated rendering paths instead. |
| **Rune / Essence segment timers** | Use their own timer visibility and precision controls, separate from the main resource text. |

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

### ### Cooldown Manager (CDM) requirements for combat tracking

Enable Blizzard Cooldown Manager and keep the relevant Tracked Bar or Tracked Buff visible.

| Bar or glow | Aura to track in CDM | Required tracking type |
| --- | --- | --- |
| Protection Paladin — Shield of the Righteous duration bar and text | **Shield of the Righteous** | **Tracked Bar only**; Tracked Buff does not supply the duration value used by this bar. |
| Protection Paladin — Consecration glow | **Consecration**, the defensive player buff (188370), not the ground-effect/totem timer | **Either Tracked Bar or Tracked Buff** |
| Blood Death Knight — Sanguine Ground glow | **Death and Decay**, the player buff (188290); Sanguine Ground must be selected | **Either Tracked Bar or Tracked Buff** |
| Unholy Death Knight — Festering Scythe glow | **Festering Scythe**, the 25-second buff (1241077) | **Either Tracked Bar or Tracked Buff** |

The **Bone Shield**, **Lesser Ghouls**, and **ground Soul Fragments** stack bars do **not** require CDM tracking. Neither does the **Moment of Craving** glow, which uses the spell-overlay signal in combat. The three optional glows above must also be enabled in the addon settings.

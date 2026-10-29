# Changelog

## 1.4.0

- Set the Devourer Demon Hunter secondary bar maximum to 40 during Void Metamorphosis. Outside Metamorphosis, retain 50, or 35 with Soul Glutton.
- Add a white divider at 30/40 during Void Metamorphosis, supporting vertical and reversed bars.

## 1.3.2

- Update README to better reflect that this addon is a fork of [SenseiClassResourceBar](https://github.com/Snsei987/SenseiClassResourceBar) and its differences.

## 1.3.1

- Add a steady gold outline to the Shield of the Righteous bar while the defensive Consecration buff is active, in and out of combat. Combat tracking requires the defensive buff in a visible Cooldown Manager Buff Icon or Buff Bar viewer; the ground-effect/totem entry does not count.

## 1.3.0

- Add a purple (`#6936af`) Protection Paladin Shield of the Righteous duration bar with a fixed 13.5-second scale, dividers at 4.5 and 9 seconds, and standard text formatting. Render duration text through the shared resource tags and formatted-text API.
- Use Blizzard Cooldown Manager aura references for SotR combat tracking while retaining the fixed 13.5-second scale; tracked buff setup is required. Match SotR cast/buff entries and read remaining seconds from its visible Tracked Bar without re-querying restricted auras or constructing timers from secret fields.

## 1.2.0

- Enable the precision dropdown for all tertiary resources when resource text is shown. Ebon Might duration text honors the selected precision; Bone Shield and soul stack counts remain integers.

## 1.1.2

- Color the Bone Shield divider after stack 5 using the default Blood rune red.
- Add a combat-only flashing gold Bone Shield warning below 5 stacks or with no aura, using Cooldown Manager tracking and an engine-evaluated stack curve.

## 1.1.1

- Rename the shared ground-soul and Bone Shield rendering helper to `AuraStackBar`.

## 1.1.0

- Add a white Blood Death Knight Bone Shield tertiary bar with stack dividers and a maximum of 10, or 12 with Improved Bone Shield.

## 1.0.0

- Add a Devourer Demon Hunter tertiary bar for ground Soul Fragments, using Blizzard aura bindings with a 10-soul scale. Absorbed souls remain on the secondary bar.
- Use a continuous fill with a white 4/10 threshold marker, with independent positioning, styling, visibility, and ground-soul color, plus standard text formats and precision. Show no text when no aura is present; resource text has no background and renders above the threshold marker.
- Replace the threshold marker with a steady white outline with a 1 px margin during Moment of Craving, using spell-overlay signals during combat (verified in game).
- Defer appearance changes while aura restrictions are active; display counts above 10 while capping the fill at 10.

## 0.1.0

- Accept legacy `SenseiClassResourceBarDB` settings when no valid `MandingaSenseiClassResourceBarDB` exists. Prefer the new database when both exist and save only the new name.
- Document SavedVariables file migration between the original addon and this fork.

## 0.0.1

- Rename the package folder to `MandingaSenseiClassResourceBar` and update texture paths.
- Update addon titles, TOC, XML, and Lua filenames, and icon metadata to match the package name, retaining `SenseiClassResourceBarDB` as the saved-variable name.
- Configure automatic GitHub Releases and CurseForge uploads to project `1770529` on `v*` tags, using `CF_API_TOKEN`. Preserve library packaging and the tag-fetch workaround; remove the original CurseForge and Wago publishing targets.

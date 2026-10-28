# Changelog

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

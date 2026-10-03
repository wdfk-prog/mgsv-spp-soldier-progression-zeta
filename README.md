# S++ Soldier Progression for Zeta

Configurable field-soldier rank progression for **Metal Gear Solid V: The Phantom Pain**, implemented as a **Zeta module** instead of a legacy `MbmCommonSetting.lua` replacer.

This mod is intended for players who want S / S+ / S++ soldiers to appear in the field without installing a legacy `.mgsv` file that replaces the same Mother Base Lua table used by other mods.

## Status

**v0.9.0-beta**

The Zeta module loads successfully in-game and its menu/settings have been tested. The complete long-term progression curves still need broader playtesting, so this is intentionally marked as a beta release.

## Requirements

- Metal Gear Solid V: The Phantom Pain
- Infinite Heaven
- IHHook
- Zeta (IH Add-on)

Zeta itself has additional installation requirements. Follow the current Zeta / Infinite Heaven installation instructions before installing this module.

## Features

- Non-replacer Zeta implementation using `MbmCommonSetting` table merging.
- No replacement of `Assets/tpp/motherbase/script/MbmCommonSetting.lua`.
- Multiple progression modes:
  - **Gradual** — vanilla early progression, then higher-rank progression later.
  - **Gradual+** — similar to Gradual, but S-rank has an early chance starting around 1% and increases as Mother Base grows.
  - **High-A Gradual** — starts field soldiers around A / A+ / A++, then progresses toward S / S+ / S++.
  - **High-A Gradual+** — High-A start plus an early S-rank chance.
  - **Custom High Ranks** — user-defined A / A+ / A++ / S / S+ / S++ weights.
  - **100% S++** — every generated base-rank roll is S++.
  - **Vanilla** — disables rank-table changes from this module.
- Optional **Fast MB Brig** setting that removes the Mother Base brig rank-time multiplier.
- In-game configuration through Zeta's Mod Management menu.

## Installation

1. Install and verify Infinite Heaven, IHHook and Zeta.
2. Remove older versions of this module, especially:
   - `mod/zeta/Spp100Zeta.lua`
   - `mod/zeta/SppSoldierProgression.lua`
3. Extract this archive into the MGSV game folder.
4. Confirm this file exists:

   `MGS_TPP/mod/zeta/SppSoldierProgression.lua`

5. Fully restart the game.
6. Open:

   `F3 -> Zeta Menu -> Mod Management -> Gameplay -> S++ Soldier Progression`

7. Set **Active = On**.
8. Select a progression mode.
9. Use **Apply / Reload**, then return to ACC or restart/re-enter the mission/free-roam area so new soldiers are generated.

## Important behavior

- Existing soldiers already spawned in the current area may not change immediately. Regenerate the area by returning to ACC or restarting/re-entering the mission/free roam.
- Until the INT-SCOPE is fully upgraded, S-rank and higher soldiers can appear as `?` / `??` instead of revealing their true grade.
- Do **not** install legacy `spp_gradual.mgsv`, `spp_gradual+.mgsv`, `spp_100%.mgsv`, or similar `MbmCommonSetting.lua` replacers at the same time unless you specifically know how their load order will interact.
- Other Zeta modules that modify `staffBaseRankRanges` can overlap with this module. Use a higher Zeta load order for the setting you want to win.
- Keep Zeta disabled for FOB/online use unless you explicitly understand the risks and the Zeta documentation says otherwise.

## Progression notes

This project is a **new Zeta reimplementation**, not an official update or redistribution of the original S plus plus Soldiers Mod.

The classic behaviors were used as design references:

- Normal gradual S -> S+ -> S++ progression.
- A Gradual+ style where S-rank can appear early at a low probability.
- A high-A variant centered on A / A+ / A++ soldiers.
- A 100% S++ option.
- Reduced Mother Base brig conversion time.

The exact full threshold table for every original variant is not publicly documented on the Nexus description page. Therefore, modes described as Gradual+ / High-A are reimplemented curves and are **not claimed to be byte-for-byte copies** of the old `.mgsv` files.

## Credits / references

- **Zeta (IH Add-on)** by ZIP / ZipfsLaw — framework and non-replacer Lua merge system.
- **Infinite Heaven** by tin man tex.
- **IHHook** by tin man tex and contributors.
- **S plus plus Soldiers Mod** by Weq23rfqew — gameplay behavior reference. Its page credits Jarhad and Rawrkanos for earlier versions.

No original `.mgsv` archive or game asset is distributed with this project.

## Development disclosure

The initial Lua implementation and documentation for this project were created with substantial generative-AI assistance and then iteratively configured and tested in MGSV. When publishing on Nexus Mods, use the **AI-Generated Content** tag in accordance with current Nexus submission guidelines.

## Uninstall

Delete:

`MGS_TPP/mod/zeta/SppSoldierProgression.lua`

Then fully restart the game. If an older `Spp100Zeta.lua` is present, remove that as well.

## License

No open-source license is included in this beta package. Add a license before public source-code redistribution if you want to grant explicit reuse/modification rights.

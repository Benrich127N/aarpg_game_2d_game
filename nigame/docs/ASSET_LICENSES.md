# Asset licensing and attribution log

Record assets when added, including placeholders. Unknown means the source or permission has not yet been verified; it does not mean the asset has a release license.

| Asset / path | Creator and source | License / permission | Attribution | Status |
| --- | --- | --- | --- | --- |
| `res://playerSprite.png` | Unknown; already present in project | Unknown | Pending source identification | Prototype only; verify or replace before distribution |
| `res://icon.svg` | Existing project icon; source unverified | Unknown | Pending source identification | Verify or replace before distribution |
| Procedural district tiles, NPC shapes, furniture and street ambience | Created in this project in `scripts/world/District.gd` and `scripts/world/Interactable.gd` | Original procedural prototype content; no third-party input assets | No third-party credit required | Source tracked with project |
| `data/dialogue.json` | Original fictional dialogue created for this project | Project-authored content | No third-party credit required | Prototype writing |

## Adding an asset

Add its exact project path, creator, original source URL or creation record, license name/version, required credit text, and any modifications. Keep a copy of the license or permission in `assets/licenses/` when available. Record font, music, sound, tileset, and sprite permissions separately. Prefer self-created placeholders while sources are unresolved. Build the release credits from verified rows.

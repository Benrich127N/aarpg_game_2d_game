# Asset licensing and attribution log

Record assets when added, including placeholders. Unknown means the source or permission has not yet been verified; it does not mean the asset has a release license.

| Asset / path | Creator and source | License / permission | Attribution | Status |
| --- | --- | --- | --- | --- |
| `res://playerSprite.png` | Unknown; already present in project | Unknown | Pending source identification | Legacy reference only; replaced by original layered art and excluded from release |
| `res://icon.svg` | Existing project icon; source unverified | Unknown | Pending source identification | Legacy reference only; original assets/game_icon.svg is the release icon |
| Procedural district tiles, NPC shapes, furniture and street ambience | Created in this project in `scripts/world/District.gd` and `scripts/world/Interactable.gd` | Original procedural prototype content; no third-party input assets | No third-party credit required | Source tracked with project |
| `data/dialogue.json` | Original fictional dialogue created for this project | Project-authored content | No third-party credit required | Prototype writing |
| Procedural player layers and wardrobe | Project-authored `scripts/characters/LayeredCharacter.gd` | Original project content; no third-party inputs | No third-party asset credit required | Used in release |
| Music, ambience, footsteps, clicks and bus effects | Project-authored `scripts/audio/AudioManager.gd` synthesis | Original project content; no samples or external recordings | No third-party asset credit required | Used in release |
| `assets/game_icon.svg` | Original project-authored vector icon | Original project content | No third-party asset credit required | Used in release |
| Godot Engine 4.4.1 Windows template | Official godotengine/godot-builds release archive | MIT and bundled dependency licences | GODOT_LICENSE.txt and THIRD_PARTY_NOTICES.txt in package | Required notices extracted from the matching engine |

## Adding an asset

Add its exact project path, creator, original source URL or creation record, license name/version, required credit text, and any modifications. Keep a copy of the license or permission in `assets/licenses/` when available. Record font, music, sound, tileset, and sprite permissions separately. Prefer self-created placeholders while sources are unresolved. Build the release credits from verified rows.

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

Main-menu update: `scripts/ui/MenuBackdrop.gd` combines the recorded prop and character sheets with original code-drawn skyline, moon, road and string lights. `scripts/ui/TitleScreen.gd` supplies native Godot typography, framed buttons and keyboard focus indicators. No new third-party images, fonts or licences were introduced. The background is static and respects reduced-motion preferences. Continue checks both the main save and backup; the existing new-game confirmation and settings/credits flows are retained. `tests/TitleMenu.tscn` verifies these states, keyboard focus, submenu returns and maximum text sizing.

HUD update: heart, food-bowl and lightning symbols in `UI/NeedIcon.gd` are original project-authored pixel patterns rendered with Godot rectangles. `UI/NeedMeter.gd` provides native framed progress bars and state labels. No external images, fonts or asset licences were added.

Character art addition: `res://assets/art/characters/{player,tunde,amara,sade,bisi,femi}-v1.png` are six AI-generated sheets created with the built-in OpenAI image generation tool, without reference images or third-party input art. No third-party attribution identified; no exclusive copyright claim. See `assets/art/characters/README.md` for source records and `generation-prompts.txt` for exact prompts. These replace procedural player/NPC visuals in the current source game. Runtime nearest-neighbour frame extraction and player wardrobe palette layers are project-authored. Terrain remains procedural. The previously built Windows package has not been rebuilt for these art changes.

Environment art addition (2026-11-10): `res://assets/art/lagos-props-v1.png` contains 12 AI-generated props made with OpenAI's built-in image generation tool for this project, without reference images or third-party input art. No third-party attribution identified; no exclusive copyright claim. Exact prompt, source generation record, atlas layout and integration notes are recorded in `assets/art/README.md` and `assets/art/generation-prompt.txt`. Used by `scripts/world/PixelArt.gd`, district decorations and interactables. Player/NPC and terrain prototypes are still in use.

Add its exact project path, creator, original source URL or creation record, license name/version, required credit text, and any modifications. Keep a copy of the license or permission in `assets/licenses/` when available. Record font, music, sound, tileset, and sprite permissions separately. Prefer self-created placeholders while sources are unresolved. Build the release credits from verified rows.

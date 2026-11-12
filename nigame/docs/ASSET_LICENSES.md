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

UI audit fixes: `scripts/characters/VenueCast.gd` supplies original code-native club idle sprites and portraits (Nneka, Kemi and Dele). `CharacterGrounding.gd` supplies a shared pixel shadow; `TargetMarker.gd` draws contextual brackets. `DistrictLandmarks.gd` provides original glass-office, palm-court and waterfront scenery. `NeighborhoodMap.gd` draws an original landmark schematic. New material details in the existing venue scripts are project-authored. No third-party images, fonts or licenses were introduced; existing PNG packs remain recorded below. These code-native assets do not include Aseprite masters.

Neighborhood maps: `scripts/world/NeighborhoodArt.gd` contains original project-authored code-drawn courtyard, shop/stockroom, cafe seating and street frontages. Club architecture remains in `scripts/world/ClubInterior.gd`. Established venue characters reuse the recorded sheets; the club cast now has original code-native sprites in `VenueCast.gd`. No new external images or fonts were added. See [Neighborhood maps](Neighborhood_Maps.md).

Room interior: plank flooring, plaster walls, windows, curtains, framed print, rug, small lamp/table, trunk and threshold in `scripts/world/RoomInterior.gd` are original project-authored native pixel drawing. The room reuses the recorded bed, desk, chair and plant atlas sprites. No third-party images, fonts or licences were added. See `docs/Room_Interior.md` for integration and validation.

Pixel controls: `UI/ControlGlyph.gd` contains original code-drawn speech, bag, phone and menu pixel symbols. `UI/ControlHintButton.gd` supplies native keycaps and raised buttons. The selection markers in `scripts/ui/PixelMenuTheme.gd` are also original code-drawn patterns. No third-party images, fonts or licences were introduced. See `docs/Pixel_Controls.md` for integration and validation.

Menu subpages: Settings, Credits and New game reuse the previously recorded props and character sheets in page-specific illustrations (`scripts/ui/MenuPageArt.gd`). `scripts/ui/PixelMenuTheme.gd` provides original native pixel frames, button states, scrollbar styling and a small code-drawn slider handle. No new third-party images or fonts were added. Shared panel styling also applies to in-game menu pages; NPC dialogue retains its bottom card.

Custom startup splash: `res://assets/art/loading/ph-night-splash-v1.png` was created for PH NIGHT using the built-in OpenAI image generation tool, with no reference images or third-party input art. No third-party attribution identified; no exclusive copyright claim. The exact prompt and source generation record are preserved in `assets/art/loading/`. Used as the engine boot splash and in `Scenes/ui/BootLoading.tscn`. Native Godot controls provide the live progress indicator; no additional font or image licence was introduced.

Main-menu update: `scripts/ui/MenuBackdrop.gd` combines the recorded prop and character sheets with original code-drawn skyline, moon, road and string lights. `scripts/ui/TitleScreen.gd` supplies native Godot typography, framed buttons and keyboard focus indicators. No new third-party images, fonts or licences were introduced. The background is static and respects reduced-motion preferences. Continue checks both the main save and backup; the existing new-game confirmation and settings/credits flows are retained. `tests/TitleMenu.tscn` verifies these states, keyboard focus, submenu returns and maximum text sizing.

HUD update: heart, food-bowl and lightning symbols in `UI/NeedIcon.gd` are original project-authored pixel patterns rendered with Godot rectangles. `UI/NeedMeter.gd` provides native framed progress bars and state labels. No external images, fonts or asset licences were added.

Character art addition: `res://assets/art/characters/{player,tunde,amara,sade,bisi,femi}-v1.png` are six AI-generated sheets created with the built-in OpenAI image generation tool, without reference images or third-party input art. No third-party attribution identified; no exclusive copyright claim. See `assets/art/characters/README.md` for source records and `generation-prompts.txt` for exact prompts. These replace procedural player/NPC visuals in the current source game. Runtime nearest-neighbour frame extraction and player wardrobe palette layers are project-authored. Terrain remains procedural. The previously built Windows package has not been rebuilt for these art changes.

Environment art addition (2026-11-10): `res://assets/art/lagos-props-v1.png` contains 12 AI-generated props made with OpenAI's built-in image generation tool for this project, without reference images or third-party input art. No third-party attribution identified; no exclusive copyright claim. Exact prompt, source generation record, atlas layout and integration notes are recorded in `assets/art/README.md` and `assets/art/generation-prompt.txt`. Used by `scripts/world/PixelArt.gd`, district decorations and interactables. Player/NPC and terrain prototypes are still in use.

Add its exact project path, creator, original source URL or creation record, license name/version, required credit text, and any modifications. Keep a copy of the license or permission in `assets/licenses/` when available. Record font, music, sound, tileset, and sprite permissions separately. Prefer self-created placeholders while sources are unresolved. Build the release credits from verified rows.

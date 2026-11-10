# PH NIGHT character pack

Six transparent PNG source sheets, generated using the built-in OpenAI image generation tool for this project without reference images or third-party input art. Exact prompts are saved in [generation-prompts.txt](generation-prompts.txt).

| File | Character |
| --- | --- |
| `player-v1.png` | Player; short natural hair, recolourable shirt and sneakers |
| `tunde-v1.png` | Delivery coordinator; mustard polo and satchel |
| `amara-v1.png` | Food vendor; coral blouse, apron and headwrap |
| `sade-v1.png` | Kiosk owner; teal outfit and short natural hair |
| `bisi-v1.png` | Adult neighbour; lavender shirt and hair puff |
| `femi-v1.png` | Stock supervisor; blue work shirt and boots |

Each source is **1182 × 1330** pixels, with **four columns and three rows**. Rows face down, up, and right. Columns are standing, stride, standing, stride. Left-facing animations mirror the right-facing row. Source dimensions differ from the requested 1024 × 1152; the runtime reads actual dimensions and rounds cell boundaries, so no fixed source-cell size is assumed.

`scripts/characters/CharacterArt.gd` extracts transparent frames, uses common bounds across each sheet to preserve relative pose offsets, and resizes once using nearest-neighbour sampling to 32 × 48. All characters render at 2× scale. The player keeps the existing foot collision and interaction range; NPCs use the existing navigation and schedule. Idle uses the first frame, and walking cycles at seven frames per second.

`LayeredCharacter.gd` separates the player's cyan shirt, dark hair, red shoes and remaining body into non-overlapping runtime palette layers. Wardrobe shirt, skin, hair colour and shoe colour choices remain functional, including the existing preview and saved state. This pack provides one hairstyle silhouette with three hair colours. Original source PNGs are preserved; frame processing and palette changes happen in Godot and are cached.

Player idle: after standing still for 0.35 seconds, `Scenes/Player.gd` applies a subtle stepped breathing transform over a 2.8-second cycle. All four wardrobe layers share the same transform, with the soles anchored and collision unchanged. It works in every facing direction, returns to the neutral pose on movement or opening a menu, and stays still with reduced motion enabled. `tests/PlayerIdle.tscn` checks breathing, foot anchoring, layer alignment, direction retention, walking transitions and reduced motion.

Validation: Godot 4.4.1 import and rendered room/street/wardrobe review completed. All five existing regression suites passed. `tests/CharacterArt.tscn` additionally verifies animation counts, visible frame content, dimensions, transparent corners, wardrobe colour changes, and non-overlapping layers.

Creation record: built-in image generation session `01a1c79a-0965-7042-a236-e47862c2ce33`. Source file IDs, in table order: `exec-699a4a6e-93b1-4b10-998c-e7d4fa0df83f`, `exec-a2db60be-77d2-4cee-86e6-91e4675dd1a9`, `exec-7bd68be9-593f-44c3-beb8-f8df3eb93d5b`, `exec-09128535-c5db-4755-b572-e3829617f056`, `exec-cf4cffa0-b861-4d2a-a1cc-b9aafd47f773`, `exec-b42e1b95-b8fe-4aae-be4a-3ba8d3bb7e2d`.

AI-generated project assets; no third-party attribution identified. No exclusive copyright or third-party licence claim is made.

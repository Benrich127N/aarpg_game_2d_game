# PH NIGHT pixel art — first environment pack

`lagos-props-v1.png` is an RGBA atlas generated with the built-in OpenAI image generation tool on 2026-11-10 for this project, using no reference images or third-party input art. The exact generation prompt is in `generation-prompt.txt`.

The delivered image is **1448 × 1086**, with four columns and three rows of **362 × 362** cells. This differs from the dimensions requested in the prompt; the runtime adapter reads actual texture dimensions. Keep the transparent gutters and use nearest-neighbour filtering. `scripts/world/PixelArt.gd` supplies AtlasTexture regions without modifying the source image.

| Row | Column 1 | Column 2 | Column 3 | Column 4 |
| --- | --- | --- | --- | --- |
| 1 | Room facade | Food stall | Provisions kiosk | Clothing stall |
| 2 | Parcels | Stock shelving | Danfo bus | Bed |
| 3 | Housing desk | Chair | Planter | Generator |

The pack is wired into the existing world interactions and placed furniture. Plants and a generator decorate the mainland. Matching player and NPC sprite sheets are in `characters/`; terrain retains its procedural prototype art. Gameplay collision and navigation remain defined by the existing world scripts; decorative plants and generator have no collision.

Source generation record: `01a1c79a-0965-7042-a236-e47862c2ce33/exec-c039cc1f-fbf1-4669-b070-4dd7c97e221a.png`. AI-generated project asset; no third-party attribution is identified. This record does not assert exclusive copyright or a third-party license.

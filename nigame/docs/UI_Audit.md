# PH NIGHT — UI, sprites and map audit

**Follow-up:** the audit fixes have been implemented. See [fixes and validation](UI_Audit_Fixes.md) and the [after screenshots](ui-audit/after/screenshots/). The original findings below remain as the before-state record.

**Audited 12 November 2026. Assessment: functional prototype with inconsistent presentation.** The most useful fixes are keyboard scrolling, consistent conversations, and clearer world interactions. A full visual redraw should follow those fixes so it supports the final layouts.

This audit found **3 high-priority, 8 medium-priority and 1 low-priority issues**. These priorities describe player impact in this prototype; they are not security or crash ratings. No release-blocking crash was observed in the final audit run. Passing functional tests does not establish visual quality.

## What was reviewed

- 31 rendered captures: room, mainland, courtyard, shop, club, three later districts, night/rain, conversations, job offer/active job, wardrobe, phone map, pause, settings and title.
- Window sizes 1280×720, 960×540, 800×600 and 640×360. Text scales 100% and 140%; long cash values and critical needs were also sampled.
- Player front/back/profile walk frames and five NPC front poses, displayed at an integer 3× zoom for inspection.
- Instrumented UI rectangles and focus positions, source inspection, and all 16 existing automated test suites, which passed.

The audit used Godot 4.7.2 with the graphical compatibility renderer. Saves were disabled and settings used an isolated project-cache path. The capture harness uses controlled scene/position setup; it is not a substitute for an independent human playthrough, physical-controller testing or a frame-by-frame animation/art review. Reduced motion was enabled for stable screenshots; walking behavior is covered by the existing tests.

Evidence: [screenshots](ui-audit/screenshots/), [measurements](ui-audit/measurements.json), [capture harness](../tests/UIAudit.gd). Screenshots are of the rendered game viewport. The 800×600 window produces an 800×450 game image under aspect preservation; window letterboxing is outside the saved viewport image.

## Findings, ordered by priority

### UI-01 · High — focused menu actions can be invisible

**Reproduction:** open Phone → Map and move focus to the final Phone home button. The shared menu scroll container does not follow focus. In the captured state, the button occupies logical y=735–785 while the visible scroll area ends at y=638; the scroll position remains 0.

**Impact:** keyboard/controller users can select an action they cannot see. Mouse scrolling can reveal it, so this is not a complete navigation lockout.

**Fix:** enable focus following in the shared scroll container, preserve focus after rebuilding a page, and verify navigation to every enabled action in long menus. The existing pause menu already enables focus following.

**Evidence:** [focused phone map](ui-audit/screenshots/12b-phone-map-keyboard-focus.png), `focused` and `menu_scroll` in the corresponding measurement. Source: [GameUI.gd](../scripts/core/GameUI.gd), shared ScrollContainer creation around line 55.

### UI-02 · High — club conversations use a different visual system

Tunde and the established neighbors use a bottom dialogue card with a portrait, speaker identity and response buttons. Nneka, Kemi and Dele open a nearly full-screen dark service menu without a portrait. A short greeting hides almost the entire venue and leaves substantial empty space.

**Impact:** the new cast feels like a separate interface. Players lose the visual connection between the person, conversation and place.

**Fix:** support venue cast in the same dialogue-card system through speaker metadata, portrait references and conversation nodes. Keep shopping and job selection in dedicated service panels.

**Evidence:** [Tunde dialogue](ui-audit/screenshots/03-dialogue.png) versus [Nneka conversation](ui-audit/screenshots/08-club-conversation.png). Source: [GameUI.gd](../scripts/core/GameUI.gd), `venue_person()` around line 225, and [DialogueCard.gd](../scripts/ui/DialogueCard.gd).

### UI-03 · High — world signage competes with the player and interaction prompts

At the shop stock counter, the large STOCK SHIFT · E label crosses the player's torso. Similar large floor labels, persistent NPC captions, the contextual prompt and the bottom Interact control all compete for attention. The problem is visible at both tested text scales.

**Impact:** the player silhouette becomes harder to read precisely where an action should be clearest.

**Fix:** move permanent signs onto walls/counters, keep them outside character standing areas, and show one concise contextual action near the selected target or in the HUD. Use a target highlight to identify which object E will activate. Check label/character overlap from every approach direction.

**Evidence:** [shop counter](ui-audit/screenshots/06-shop.png), [smaller-window shop](ui-audit/screenshots/20-small-large-text-hud.png). Source: [District.gd](../scripts/world/District.gd), `sign_text()` around line 101 and stock sign around line 279; [InteractionDetector.gd](../scripts/player/InteractionDetector.gd).

### UI-04 · Medium — Close receives primary focus on routine action panels

The first focused action on both a job offer and an active club shift is Close. The most visually emphasized default action therefore exits the panel rather than starting work or serving a drink.

**Fix:** make the panel's intended action the default focus; move Close to a consistent secondary location. Closing an active job panel and cancelling the job must remain clearly distinct.

**Evidence:** [offer](ui-audit/screenshots/09-job-offer.png), [active shift](ui-audit/screenshots/10-job-active.png). Source: [GameUI.gd](../scripts/core/GameUI.gd), `frame()` inserts Close around line 128 and `button()` chooses the first enabled button around line 153.

### UI-05 · Medium — environment art has visibly different levels of detail

The room's bed, desk and plant have detailed textures and shading. Club furniture, courtyard plants, shop crates and new street frontages are broad, flat rectangles. The original stalls and new frontages appear together on the mainland, making the difference especially clear. Club staff also reuse recognizable existing NPC sprites.

**Fix:** define a shared material/shading and pixel-density guide before the Aseprite pass. Redraw new venue props at consistent source sizes, then give the club cast distinct silhouettes. Preserve the successful warm room palette and readable club floor layout.

**Evidence:** [room](ui-audit/screenshots/01-room.png), [street seating](ui-audit/screenshots/04-street-seating.png), [courtyard](ui-audit/screenshots/05-courtyard.png), [club](ui-audit/screenshots/07-club.png). Source: [NeighborhoodArt.gd](../scripts/world/NeighborhoodArt.gd), [ClubInterior.gd](../scripts/world/ClubInterior.gd), [PixelArt.gd](../scripts/world/PixelArt.gd).

### UI-06 · Medium — player grounding differs from NPC grounding

The player remains recognizable in front/back/profile views, and the sampled animation frames retain the same costume. However, the player lacks the obvious ground shadow used for NPCs. The player visual origin is y=-22, while NPC and venue-person sprites use y=-34, a 12-world-pixel difference before camera scaling. This makes common anchor coordinates represent different visual foot positions.

**Fix:** define a common foot-anchor convention and shadow style. Align visual origins with collision and interaction anchors deliberately; do not simply change the sprite offset without checking walls, doors and interaction range. During redraw, preserve the player's clear shirt/trouser separation and simplify uneven facial/limb clusters at the native frame size.

**Evidence:** [player beside Tunde](ui-audit/screenshots/02-player-and-npcs.png), [3× sprite inspection](ui-audit/screenshots/29-sprite-closeups.png). Source: [Player.gd](../Scenes/Player.gd), `VISUAL_ORIGIN` at line 10; [NPC.gd](../scripts/npc/NPC.gd), sprite origin around line 19; [VenuePerson.gd](../scripts/world/VenuePerson.gd).

This is a grounding/consistency finding, not evidence that the wardrobe or walking systems are broken. Existing player-walk and NPC-eye tests passed.

### UI-07 · Medium — the HUD reserves a large amount of vertical space

At 1280×720, the top HUD panel is 122 pixels high and ends at y=142. The contextual prompt begins near y=596. That leaves a 454-pixel central vertical band between them. At 140% text size, the top panel grows to 145 pixels high, leaving about 431 pixels. These are vertical layout bands, not percentages of the entire screen covered by opaque UI.

**Fix:** use a more compact normal-state HUD, reveal detailed need descriptions when low or inspected, and reduce the permanent bottom dock for keyboard play. Keep critical states readable and available without relying on color alone.

**Evidence:** [room HUD](ui-audit/screenshots/01-room.png), [large text](ui-audit/screenshots/20-small-large-text-hud.png), [critical needs](ui-audit/screenshots/28-critical-needs-long-cash.png). Source: [hud.gd](../UI/hud.gd), UI construction around line 38; [NeedMeter.gd](../UI/NeedMeter.gd).

### UI-08 · Medium — text enlargement does not cover world labels

NPC/object captions use a fixed 15-pixel font; map signs use 24 pixels. Increasing text size affects menus, HUD and dialogue but leaves these labels unchanged. At a 960×540 window, the 15-pixel caption renders at approximately 11.25 screen pixels because the 1280×720 layout is scaled down.

**Fix:** distinguish decorative signage from essential information. Scale essential target names through a screen-space prompt with the accessibility setting. Avoid enlarging every world label permanently, which would worsen crowding.

**Evidence:** [140% HUD with small world captions](ui-audit/screenshots/20-small-large-text-hud.png). Source: [Interactable.gd](../scripts/world/Interactable.gd), label font around line 47; [District.gd](../scripts/world/District.gd), sign font around line 106.

### UI-09 · Medium — later districts have little visual identity

Business District, Lekki and Island show the same basic layout and repeated kiosk, stock shelf and bus arrangement, with palette changes. They read as variants of a test map despite being presented as distinct destinations.

**Fix:** give each district a distinct silhouette, landmark and useful destination before presenting it as a major progression reward. First improve the mainland's paths, facades and activity cues; then expand districts when the story needs them.

**Evidence:** [business](ui-audit/screenshots/13-business.png), [Lekki](ui-audit/screenshots/14-lekki.png), [Island](ui-audit/screenshots/15-island.png). Source: [District.gd](../scripts/world/District.gd), shared `_district()` around line 195.

### UI-10 · Medium — very small windows make the interface unreadable

The game allows a 640×360 window. The layout remains inside the viewport, but a 12-pixel hint becomes approximately 6 screen pixels at 100% text size. Fitting controls is not the same as making them readable.

**Fix:** establish a minimum supported window size after testing on the intended display, or add a compact small-window layout with larger essential text. For 4:3 windows, retain deliberate letterboxing rather than stretching the art.

**Evidence:** [640×360](ui-audit/screenshots/25-tiny-window.png), [4:3 viewport output](ui-audit/screenshots/24-four-three-window.png). Source: [project.godot](../project.godot), display settings around line 35.

### UI-11 · Medium — the phone map does not provide spatial navigation

The map is a long text list of fares, cardinal directions and raw NPC coordinates. It has useful information but no visual relationship between the room, courtyard, shops, seating and club. Essential destination information also competes with the schedule list.

**Fix:** add a small neighborhood diagram with named landmarks, current location and the active objective. Keep transport fares in a separate district section and NPC schedules in contacts. A simple schematic is sufficient; a full minimap is not necessary.

**Evidence:** [phone map](ui-audit/screenshots/12-phone-map.png). Source: [PhoneUI.gd](../scripts/ui/PhoneUI.gd), map branch.

### UI-12 · Low — wardrobe controls use vague and misleading names

Skin style 2, Hair style 1 and Shoes style 1 do not tell the player what will change. In the current renderer, hair variations change color rather than hairstyle silhouette. Rebuilding the page after each change also returns focus to Close.

**Fix:** name the properties Skin tone, Hair color and Shoe color, show named swatches or previous/next choices, and retain focus on the changed property. If true hairstyle silhouettes are later added, expose them as a separate control.

**Evidence:** [wardrobe](ui-audit/screenshots/11-wardrobe.png). Source: [GameUI.gd](../scripts/core/GameUI.gd), wardrobe controls around line 484; [LayeredCharacter.gd](../scripts/characters/LayeredCharacter.gd), `variant` currently only changes the cache key.

## What is working

- The established NPC dialogue card has a readable portrait/name hierarchy and clear response focus. At 960×540 and 140% text, the tested Femi conversation fits above the bottom edge. A capture from beside the actual speaker keeps both characters visible.
- The top HUD clearly separates cash, location, time and needs. Critical states have both text and color cues. The tested billion-naira balance and critical needs fit without overlapping.
- The room has the strongest visual cohesion. Title and pause pages have clear grouping and a consistent green/gold identity.
- Fixed interior cameras frame the new venues. The sampled northwest and southeast street positions keep the player visible and clear of the HUD/dock. This sample does not establish that every possible position or aspect ratio is defect-free.
- Existing tests passed for dialogue input/pagination, walking synchronization, NPC eyes, HUD controls, room boundaries, neighborhood travel and save persistence.

## Recommended fix order and acceptance checks

| Pass | Work | Acceptance check |
| --- | --- | --- |
| 1 — Navigation and clarity | UI-01, UI-03, UI-04 | Every focused button scrolls into view; routine panels focus their main action; no essential sign crosses a character at an interaction point. |
| 2 — Conversation consistency | UI-02 | Every speaking character uses one dialogue pattern with a name/portrait; service panels remain distinct and return to a predictable context. |
| 3 — Layout and accessibility | UI-07, UI-08, UI-10 | At the minimum supported window and 140% text, essential names, prompts and actions remain legible; critical needs remain understandable. |
| 4 — World and sprite presentation | UI-05, UI-06, UI-09 | Shared foot anchors, shadows and material style; venue cast distinguishable; each district has a recognizable landmark. |
| 5 — Navigation tools and customization | UI-11, UI-12 | A new player finds a destination without coordinates; wardrobe choices clearly describe their effect and retain focus. |

Fix navigation and interaction layout before redrawing all assets. Use the [Aseprite workbook](Aseprite_Redraw_Guide.md) for the art pass.

## Reproduce the captures

Run Godot graphically with the project path and `res://tests/UIAudit.tscn` as the scene. The harness writes PNGs under `docs/ui-audit/screenshots/` and layout/focus data to `docs/ui-audit/measurements.json`. It does not use the player's save slot. `docs/ui-audit/.gdignore` keeps evidence files out of Godot's asset import.

The original audit added evidence and a repeatable inspection scene without changing gameplay. The subsequent implementation and validation are recorded in [UI audit fixes](UI_Audit_Fixes.md).

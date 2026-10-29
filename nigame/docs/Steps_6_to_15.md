# Steps 6–15 — playable prototype

Run `project.godot` and press F5. The entry scene is now `scenes/main/Main.tscn`. The older `Scenes/test_world.tscn` remains the movement regression sandbox. New systems are small working prototypes, with procedural art and short fictional dialogue rather than final content.

## Controls and first day

| Key | Action |
| --- | --- |
| WASD / arrows | Move |
| E | Interact with the nearby labelled object or NPC |
| I | Bag; consume food/water; inspect or cancel the current job |
| J | Quest journal and reward claims |
| P | Phone contacts and relationship values |
| C | Career, net worth, progression requirements, achievements |
| K | Manual save while outside menus |
| Escape | Close the current panel, or open the pause menu |

A fresh game starts at 07:00 in your room. Walk to the street door and press E. Tunde is south-east of the room; greet him and ask about delivery work. Start the delivery, close the panel, collect the parcel beside him, and take it to Bisi east of the kiosk. Hand it over to receive ₦750 once. Visit Amara's stall or Sade's kiosk, buy food, press I and consume it. Return through your room's door, interact with the bed, and sleep. This advances to 07:00 tomorrow, restores energy, and autosaves. Open J to claim the first-day quest after completing its five objectives.

One successful delivery unlocks Femi's stock shift. At the shift, choose the item matching each requested shelf; three correct matches pay ₦1,200. A wrong match or cancellation ends the job without pay. Both jobs cost energy when accepted and have cooldowns. Use I or J to reopen an active job; finish or cancel it before sleep or district travel. Closing the stock panel does not cancel or reset its sequence.

## Implemented systems

| Guide step | Implementation |
| --- | --- |
| 6 · Interaction | `scripts/world/Interactable.gd` contract, player's Area2D detector, proximity prompt, priority/nearest/stable tie ordering, input blocking during menus. Doors, bed, shops, NPCs, parcel, housing and transport objects use the same contract. |
| 7 · NPC/dialogue | Reusable `scenes/npc/NPC.tscn`, five stable identities, JSON greetings/advice, branching role choices, per-NPC flags, optional Bisi interest branch. First daily greeting raises friendship/trust; repeated greetings do not farm values. |
| 8 · Jobs | Resource-backed delivery and stock matching minigames, eligibility, energy costs, cooldowns, progress, success/failure/cancellation and token-checked one-time pay. Delivery requires both collection and the correct recipient. |
| 9 · Inventory/shops | Resource item catalog, eight distinct stack slots, item stack limits, add/remove/use, two shop catalogs, atomic purchase validation, bag UI. |
| 10 · Mainland | Generated 32-pixel TileMapLayer ground/road/collision layers, rented room, labelled street, five NPCs, two shops, job locations, original procedural ambience and night tint. |
| 11 · Save/load | Validated versioned JSON, same-directory temporary writes and rename, previous-valid backup, recovery/migration, manual save/load, autosave after travel, completed UI jobs and sleep. Startup continues the saved slot. |
| 12 · Districts | Persistent player/HUD plus replaceable world scenes; fare/time validation; named spawn markers; Mainland, Business District, Lekki and Island prototypes. Job/inventory/dialogue/world state survives travel. |
| 13 · Economy | Cash separated from property-inclusive net worth, reputation and job-count class gates, achievements, career screen, recurring rent and transport costs, `data/economy_balance.csv`. |
| 14 · Housing | Starting rented room, larger courtyard apartment rental/purchase, weekly rent invoices, arrears payment, sleep, chair inventory, grid placement/storage and persistence. |
| 15 · Relationships/quests | Per-NPC friendship/trust, explicit optional adult interest branch, Resource-backed two-quest chain, event-driven objectives, one-time claims, journal and phone contacts, saved flags/values. |

`Game` is the long-lived AutoLoad that owns the managers as named child nodes. Use `Game.jobs`, `Game.inventory`, `Game.dialogue`, `Game.scenes`, `Game.progression`, `Game.housing`, `Game.relationships`, `Game.quests` and `Game.save`. Global continues owning cash/needs; TimeManager owns the clock. This keeps manager lifecycle in one place. Existing `Scenes/` and `UI/` paths remain intact; new content uses the guide's `scenes/`, `scripts/` and `resources/` conventions. NPCs are stationary Area2D interactables in this milestone; walking schedules and navigation are Step 16 work.

## Progression and housing

Professional requires **all three**: net worth ₦12,000, reputation 10, and three completed jobs. It unlocks Business District and Lekki. Established requires net worth ₦100,000, reputation 40, and ten jobs, and unlocks Island. The expansion districts have small walkable layouts, a provisions shop, stock work and return transport; they are not finished districts. Return to Mainland to enter your home.

The room's first week is prepaid; ₦700 becomes due on day 8 and every seven days after that. The apartment costs ₦2,500 per week to rent or ₦30,000 to own. Arrears must be settled before changing housing. Rent debt does not evict the player or block the basic earning loop. Buying a home removes its recurring rent. Chairs cost ₦400; one starts in storage. Furniture placement uses explicit grid positions, rejects occupied/protected cells, and can be undone by storing the last chair. The optional Bisi interest branch requires friendship 20 and can be accepted once; it is an introductory branch, not a full romance simulation.

## Save behaviour

The player slot is `user://saves/slot_1.json` with `.tmp` and `.bak` siblings. Godot's **Project → Open User Data Folder** locates it. The schema stores stats, clock, district/position, inventory, active job/sequence/cooldowns, conversation flags, relationships, quests/claims, housing/ownership/rent/furniture and achievements. UI nodes are never serialized. Incomplete jobs resume; completed reward tokens cannot pay again after reopening.

A missing/corrupt slot leaves a fresh or current session intact, with recovery from a valid backup when available. Version 1 core saves migrate using clean defaults for later systems; unknown future versions and invalid nested data are rejected before mutation. The current version is 2. Loading a position that overlaps a solid wall falls back to that district's spawn after physics settles. Valid cash saves are bounded to ₦1 billion and clock days to one million; invalid current state reports a save error rather than silently truncating it. Backup files are only replaced with a validated prior slot.

Pause → Save/Load provides manual actions. Pause → New game asks before resetting the session; it does not immediately erase the disk slot. A later save/autosave replaces the slot while preserving its prior valid backup. No automatic save occurs merely by closing the window, so use K or the pause menu after changes you want to keep.

## Verification

- `tests/Steps6To15.tscn`: end-to-end automated integration checks across the fresh daily loop, real proximity input, all five NPC greetings/advice, overlap priority, UI job callbacks, paid/failed/repeated jobs, shop restrictions/capacity/funds, food use, quest prerequisites/claims, rent, furniture, district locks/costs, ownership/net worth, invalid saves, backup recovery, and migration.
- `tests/PersistenceRestart.tscn -- write`, then the same scene in a **new Godot process** without `write`: verifies persistent state and one-time delivery payout after restart. Test files live in ignored `.godot/` directories and never use the player's save slot.
- `tests/Steps3To5.tscn`: existing movement, clock, pause and HUD regression checks.
- `tests/VisualReview.tscn`: renderer captures of the room, street, dialogue and shop in `.godot/review-*.png`. Requires a rendering window; do not use the dummy headless renderer for captures.

The implementation has been exercised automatically and initial screens visually inspected with Godot 4.4.1. A human full-day playtest, listening to ambience, balancing earnings/rent, and reviewing every panel at smaller sizes remain review tasks. These prototypes are not a Windows release build. No Git staging/commit was attempted because staging was declined earlier in this session.

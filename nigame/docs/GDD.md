# Lagos Life Simulator — Game Design

Status: initial design baseline; implementation is tracked in [the roadmap](../Development_Roadmap.md).

## Player fantasy and audience
Build a life on a fictional Lagos mainland street: meet neighbours, earn a living, buy food, and return to your rented room. Aim for a welcoming, grounded life sim for players who enjoy everyday choices, light job minigames, and Nigerian neighbourhood stories. Use fictional characters and businesses; give each neighbour goals beyond their job.

## Core loop and first ten minutes
Wake → explore → talk → work → get paid → shop → eat → return home → sleep → save and continue.

The following is the intended experience once the MVP is built, not a claim about current functionality:

| Real play time | Player action and visible result |
| --- | --- |
| 0–2 minutes | Wake at 07:00 in the rented room; read movement and interaction prompts; walk outside. |
| 2–4 minutes | Meet the delivery coordinator, choose a dialogue option, and accept a short local delivery. |
| 4–6 minutes | Walk a parcel to the marked neighbour and finish the job; receive pay once and see energy decrease. |
| 6–8 minutes | Visit the food stall, buy food, and consume it from inventory; cash decreases and hunger satisfaction rises. |
| 8–10 minutes | Return to the room and choose sleep; advance to the next morning, restore energy, and save. Quit and reopen to continue. |

## Twelve-week MVP boundary
One walkable street and one room; five named NPCs with short branching conversations; two jobs (local delivery and stock matching); two shops (food stall and provisions kiosk); cash, hunger, energy, health, clock, simple inventory, sleep, and one save slot. The five roles are a delivery coordinator, food vendor, kiosk owner, neighbour/parcel recipient, and stock supervisor. All destinations are on this street. Start with the room available; rent collection comes later. Sleep can end the day early so the introductory loop fits ten minutes.

Job failure gives no pay; successful completion pays exactly once. Purchases require sufficient cash and inventory space. Store money as integer naira. Needs use 0–100, where higher means healthier, better fed, or more rested. Initial values and prices are prototype tuning values, not real Lagos prices. Keep one job available without an upfront fee to avoid trapping a broke player.

## Presentation and controls
Top-down 2D pixel art with warm earth tones, colourful storefronts, and readable silhouettes. Use a 32×32 world tile grid and approximately 32×48 character frames; align feet and collision shapes to the ground. Start with labelled placeholders and keep text readable. Use the 1280×720 viewport configured in Step 2, with scalable UI.

First target: Windows desktop, keyboard and mouse. WASD or arrows move; E interacts; I opens inventory; Escape pauses/closes menus; mouse or arrows plus Enter selects menu choices. Normalize diagonal movement. Gamepad and Android touch support are deferred.

## Acceptance criteria
A fresh game lets a tester wake, leave the room, talk, complete a job, receive pay once, buy and consume food, return, and sleep without editor intervention. Both jobs and both shops work, all five NPCs respond, walls block movement, and needs stay within bounds. Saving, quitting, and reopening restores cash, needs, time/day, inventory, location, and dialogue/job flags. Failed jobs pay nothing; unaffordable purchases change nothing. A Windows export runs outside the editor.

## Deferred features
Additional districts and transport, driving/traffic AI, businesses/investments, property buying/furniture, recurring rent, romance/family, deep relationships/quests, dynamic crowds/weather, clothing customization, a full phone, gamepad, and mobile controls. Revisit these after the saved daily loop works. Use original or licensed assets tracked in [the asset log](ASSET_LICENSES.md).

Schedule and milestone checks: [MVP plan](MVP_Plan.md).


Implementation update: the subsequent request for Steps 6–15 added small district, progression, housing and relationship/quest prototypes after the saved daily loop passed integration checks. See [the implementation notes](Steps_6_to_15.md) for the current playable scope; the release target above remains the baseline.

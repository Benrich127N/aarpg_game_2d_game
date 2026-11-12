# Neighborhood maps

The first neighborhood now connects the player room, community courtyard, provisions shop/stockroom and PH Night Club through the mainland. Amara's outdoor seating stays on the mainland map.

| Place | Entrance on the mainland | Activities |
| --- | --- | --- |
| Player room | Northwest, existing room frontage | Sleep, housing and furniture |
| Community courtyard | Southwest gate, (320, 880) | Meet Bisi, inspect the garden plan, rest on the bench, open the food bag |
| Provisions / stockroom | North-side kiosk frontage, (960, 336) | Talk to Sade and Femi, buy provisions, complete stock shifts |
| Amara's seating | South-central tables, (736, 912) | Browse food, eat from the bag, take a break |
| PH Night Club | Southeast entrance, (1280, 880) | Bar shifts, supervisor/guest/DJ conversations and a dance activity |

Use E near an entrance or activity. Local entrances are free and do not advance time. Each separate venue returns to its own mainland doorway. Active jobs must be completed or cancelled before changing scenes.

Courtyard and shop scenes are `Scenes/world/courtyard/Courtyard.tscn` and `Scenes/world/provisions/Provisions.tscn`. They use solid boundaries, collision for the major furniture, fixed cameras and safe spawns. Save/load restores location, player position and existing job state. The existing save schema supports these additional destinations without new fields.

The courtyard includes raised beds, paths, benches, a noticeboard, a barrel and bunting. The shop includes stocked shelves, a service counter and a separate stock area. The mainland includes courtyard/club frontages and cafe tables. `scripts/world/NeighborhoodArt.gd` draws these original code-native pixel shapes; `District.gd` places collisions and interactions.

`VenuePerson.gd` supplies stationary venue characters. Bisi, Sade and Femi use their existing dialogue and relationship state. Club supervisor Nneka, guest Kemi and DJ Dele have distinct code-native idle sprites and matching portraits in `VenueCast.gd`. They use the same bottom dialogue card as the established cast. They do not yet have relationship meters, walking animations or schedules.

Bench/cafe rest advances 15 minutes and restores 5 energy. Dancing advances 10 minutes and costs 5 energy; it currently presents an activity result rather than a bespoke dance animation. These actions do not award cash. Existing food prices, stock-job requirements and rewards still apply.

The garden plan is an inspectable location and conversation opportunity. The proposed garden/showcase quest chain and full story episode remain in the [comparison plan](Nights_Comparison_and_Plan.md); creating these maps does not implement that episode.

`tests/NeighborhoodMaps.tscn` verifies reachable interactions, walking routes, door return positions, free travel, purchases, stock work, rest/dance costs, venue conversations, boundaries and saving/loading inside the new maps. It is included in `tools/test.ps1`. A graphical run also saves review screenshots under `.godot/review-neighborhood-*.png`.

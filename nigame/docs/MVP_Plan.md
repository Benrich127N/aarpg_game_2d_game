# Twelve-week MVP plan

These are relative development weeks, not promised calendar dates. Existing scripts are prototypes until their acceptance checks pass. Finish each milestone before expanding scope.

| Weeks | Guide steps | Deliverable and exit check |
| --- | --- | --- |
| 1–2 | 1–3: planning, foundations, player | Design and attribution log exist; project launches; player moves, collides with walls, and has consistent diagonal speed. |
| 3–4 | 4–5: state, time, HUD | Cash and bounded needs update through signals; clock crosses midnight correctly; HUD scales with the window. |
| 5–6 | 6–7: interaction, dialogue | E selects one nearby target; dialogue blocks movement; five NPCs have tested branches and persistent flag data ready for saving. |
| 7–8 | 8: jobs | Delivery and stock matching each support success/failure, energy cost, and exactly-once rewards. |
| 9–10 | 9–10: inventory, shops, street | Two shops validate purchases; eating restores hunger; one street and room support a complete wake/work/eat/sleep loop. |
| 11–12 | 11 plus minimum release checks | Save/load restores the full loop; missing/corrupt saves recover safely; a Windows build runs outside the editor; a tester completes the loop and restarts from a save. |

## Scope gate

Guide steps 12–19 are later expansion and full release work. Bring forward only the minimum pause/title/credits UI, export setup, and defect fixing needed to test the MVP. Do not build new districts or advanced systems to fill a milestone. If a week slips, reduce dialogue length and decoration before cutting the complete saved daily loop.

## Step 1 review

- [x] Fantasy and audience documented in GDD.
- [x] Top-down art direction and tile scale chosen.
- [x] Compact game design document created.
- [x] Twelve-week scope and deferred features defined.
- [x] First-playable success criteria and ten-minute walkthrough written.
- [x] Windows target and input scheme chosen.
- [x] Asset licensing log created; unknown sources explicitly recorded.

Planning acceptance review: every action in the ten-minute walkthrough belongs to the MVP above. It requires no district travel, vehicle, relationship, or property system. Gameplay verification remains part of later milestones.

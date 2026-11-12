# PH NIGHT compared with the Java Nights games

Research and source-code review: 12 November 2026. This is a proposed design and implementation plan; the new story and systems below have not been implemented.

## Scope and conclusion

The comparison uses **Paris Nights** and the original **New York Nights: Success in the City** for Java-era phones. New York Nights 2: Friends for Life is a separate game; its plot should not be mixed into the first game's story. Handset versions may differ. This review uses contemporary coverage and a Paris Nights designer's account, rather than claiming a complete scene-by-scene playthrough.

PH NIGHT has a working daily survival/economy loop. Its largest gap is the connection between social choices, personal growth, story missions and opportunities. More places and higher cash thresholds alone will not supply that connection.

## What the reference games do

### New York Nights: Success in the City

**Story premise:** a young newcomer has 40 days to make a success of life in New York. Career, friendships and romance form the main ambitions, under limited starting funds and time. [Contemporary hands-on](https://www.gamespot.com/articles/new-york-nights-success-in-the-city-hands-on/1100-6117789/), [game description](https://www.mobygames.com/game/25968/new-york-nights-success-in-the-city/).

**Loop:** maintain needs → improve personal attributes → meet people and learn their interests → build relationships → gain work and dating opportunities → earn through minigames → invest in appearance and activities → repeat toward success. Friends help the player find work; dates and suitable conversation develop relationships. [GameSpot review](https://www.gamespot.com/reviews/new-york-nights-success-in-the-city-review/1900-6122065/).

**Design lesson for PH NIGHT:** money, relationships and self-improvement should enable one another. A friend should change what the player can do, and a new job should create social situations as well as income. This is our design inference, not a quoted rule from its developers.

### Paris Nights

**Story premise:** arrive with a suitcase and no home, then establish a life through contacts, personal development and required story objectives. The Java review describes a largely fixed main storyline with freedom in activities and character development. [Pocket Gamer's Java review](https://www.pocketgamer.com/paris-nights/review/).

One contemporary account describes finding a flatmate and work, followed by a luggage mix-up that sends the player toward the Louvre. It describes the larger arc as building fame and fortune through careers and connections. This supports an early plot hook, not a verified reconstruction of every later chapter or ending. [Game Over Online review](https://www.game-over.net/reviews/hand/Paris_Nights.html).

**Loop:** explore → acquire an objective → discover a social or attribute requirement → improve or build the right relationship → complete the mission → access another encounter or activity → manage daily life between missions. The game's designer describes mission interactions controlled by variables, NPC interests, and dates that unlock activities and cutscenes. [Danny Godin's original Java design portfolio](https://www.coroflot.com/godind/Paris-Nights-Gameloft-2008).

**Design lesson for PH NIGHT:** a location gains value when a mission or relationship gives the player a reason to visit it again. Story progress should visibly change interactions in familiar places.

## PH NIGHT: implemented behavior and gaps

Evidence comes from the current scripts and resources, rather than the older roadmap's completion labels.

| Area | Current PH NIGHT | Missing depth / recommended change |
| --- | --- | --- |
| Daily loop | Wake, explore, work, buy/eat food, sleep and save | A reason to choose today's activities beyond repeating income |
| Main story | Two chained quests: Find your feet and A familiar face | Opening incident, chapters, conflict, payoff and a clear episode ending |
| NPC dialogue | Five named NPCs; greetings, advice and a few service actions | Interests, contextual responses, player choices with remembered consequences |
| Relationships | Daily greeting raises friendship/trust; Bisi has one interest action | Friendship milestones, invitations, favors, disagreements, dates and optional romance progression |
| Personal development | Needs, reputation, completed jobs and wealth | Learnable skills tied to useful actions and conversations |
| Work | Delivery, stock matching, club drink matching | Job ranks, contextual requests, different play patterns and performance feedback |
| Club | Separate interior, fixed camera, bar shift and exit | Staff/guests, social activities, event schedule and a story role |
| City | Mainland plus business, Lekki and Island prototypes | Distinct activities and story reasons for each destination; later districts repeat basic services |
| Progression | Wealth/reputation/job-count tiers | Personal introductions and narrative milestones alongside financial gates |
| Housing | Rent, apartment, chairs and sleep | Character visits and home scenes; more furniture can follow later |
| Events | Rain, traffic, helping a neighbor; NPC schedules | Authored appointments and story events that follow earlier decisions |
| Presentation | Character/prop sheets, code-drawn environments, UI and synthesized audio | Bespoke venue art, more character acting, authored story moments and clearer next-goal feedback |

Source anchors: `scripts/quests/QuestManager.gd`, `resources/quests/`, `data/dialogue.json`, `scripts/dialogue/DialogueManager.gd`, `scripts/relationships/RelationshipManager.gd`, `scripts/jobs/JobManager.gd`, `scripts/economy/SocialClassManager.gd`, `scripts/events/EventManager.gd` and `scripts/world/District.gd`.

Do not add every meter from the older games. Hygiene and bathroom needs could add flavor, but they are lower priority than meaningful dialogue, skills and missions. Keep romance optional and let friendship support the main ending.

## Club pixel art: yes, with a precise qualification

**Yes:** `scripts/world/ClubInterior.gd` draws original pixel-style architecture with hard-edged shapes: tiled floor, bar and bottles, stools, DJ booth, speakers, seats, neon trim, dance floor and exit mat. The separate scene is `Scenes/world/club/Club.tscn`.

**There is no dedicated club PNG atlas or Aseprite master yet.** The current artwork is simple code-drawn placeholder art, not a finished illustrated venue pack. No new club guest or staff sprites were created. The later Aseprite redraw can replace these visuals using the [redraw workbook](Aseprite_Redraw_Guide.md) and [club palette](art/palettes/ph-night-club.gpl).

## Proposed identity and core loop

Keep the current fictional Lagos setting as the planning baseline, matching the GDD and existing districts. Settle any intended change of city before writing substantial location-specific dialogue.

**Player promise:** build a life and a place in the neighborhood while helping put on a community showcase at PH Night Club.

**Target loop:** choose a personal/story goal → talk and learn what matters → work or practice a skill → spend time and money preparing → return for a social/story encounter → gain a relationship milestone or opportunity → rest and see the next consequence.

Every mission should advance at least two of these: livelihood, relationships, personal growth, or the shared story. Cash remains useful, but cannot substitute for every interaction.

## Proposed first episode: A Place in the City

This is an original proposed PH NIGHT story, not the storyline of either Gameloft game.

The player settles into a rented room with limited savings. Bisi wants to turn the neglected courtyard into a useful community space. The club offers a showcase night to raise support, but the neighborhood needs someone to connect the vendors, deliveries and preparations. Helping creates a route toward steady work and belonging.

| Chapter | Story and playable objective | Visible result |
| --- | --- | --- |
| 1. Find your feet | Expand the existing tutorial: meet Tunde, deliver, eat, return home | First pay, established contacts, one clear next objective |
| 2. Meet the neighbors | Learn Bisi's courtyard goal; choose to help through supplies or introductions | A remembered choice and a practical invitation |
| 3. First club shift | Meet a club supervisor, complete training, learn about the showcase | Club contact, shift rank and event quest |
| 4. Earn their trust | Amara needs supplies; Femi needs a careful stock hand; choose task order | Vendors commit to the event; NPC dialogue changes |
| 5. A scheduling problem | A delivery conflict overlaps an invitation; choose, notify, or reschedule | Different scene and relationship response, with a recovery route |
| 6. Showcase night | Complete a preparation checklist and a distinct service challenge | Event scene that reflects preparations and relationships |
| 7. Your next step | Receive a steady-work offer and neighborhood acknowledgement | Episode ending, outcome summary and optional free play |

Use a seven-day target for initial tuning, not an automatic game-over deadline. Late players can reschedule and recover. Friendship can complete the episode; an optional date with Bisi can add a separate scene. Test this episode before planning another large map.

## Implementation sequence

These are ordered milestones, not calendar promises. Finish each exit check before expanding.

| Priority | Deliverable | Implementation scope | Exit check |
| --- | --- | --- | --- |
| 1 | Story spine and next objective | Add chapter state and quest events for specific actions, such as a successful delivery or completed club shift. Show active objective and destination. | A fresh player can finish the opening and always identify the next step. Old saves receive safe defaults. |
| 2 | Stateful NPC conversations | Extend dialogue data with node IDs, conditions, options and effects. Add interests and friendship milestones to the existing cast. | An NPC remembers a choice; a milestone unlocks an introduction or activity; repeated choices cannot duplicate rewards. |
| 3 | Two useful skills | Add service and creativity, with progress from relevant actions and clear requirements. Service supports jobs; creativity supports the showcase and courtyard. | Each skill unlocks a visible action, with an explained way to improve. Growth survives saving. |
| 4 | Club as a social venue | Add supervisor and guests, conversation points, a dance interaction, appointments, and a quest board or supervisor prompt. | Visit without working and still have a useful social/story activity. An invitation can succeed, expire or be rescheduled. |
| 5 | Work progression and episode finale | Add training/regular/event shifts, varied guest requests, performance feedback and the showcase. | Jobs differ in play, the finale reflects preparations, and the episode has a reachable ending. |
| 6 | Art pass and balancing | Replace club placeholders with Aseprite assets; enrich key story poses; tune income, energy, travel and progression. | A human tester completes the episode without guidance and has reasons to vary daily activities. |

Start milestone 1 with a small playable chain: **finish first_day → Bisi invitation → meet club supervisor → finish club training → return to Bisi**. This proves that the social/story loop works before writing the full episode.

## Technical integration notes

- `QuestManager.gd` currently records generic events such as `job`. Add typed events with context so a delivery objective cannot accidentally complete through a stock or club job.
- Use a small story service or resource-driven chapter state. Keep story conditions out of scattered UI callbacks. Expose state changes through signals.
- Give dialogue nodes stable IDs; separate one-time effects from repeatable conversation. Keep the existing service buttons available so a story cannot block basic food, work or sleep.
- Add skills and appointments to validated save state. Bump the schema when these fields ship and migrate version 3 saves with deterministic defaults. Save chapter progress, choice flags and claimed rewards; do not infer them from cash.
- Appointments need explicit start/end windows, late behavior and recovery. Do not silently delete an invitation on load or require a missed event to complete the story.
- Review `GameUI.gd`, `PhoneUI.gd` and the HUD together: objective, appointment and job information must agree.
- Define one useful activity and one authored encounter for each district before adding more destinations. Existing prototype districts can wait until the first episode needs them.
- Keep visual asset work separate from changes to collision and spawn boundaries. Redrawing a venue does not require changing its walkable layout.

## Balance and playtest questions

The current club pays ₦1,500 for a 60-minute shift, costs 20 energy and has a 180-minute cooldown. Three correct untimed drink choices complete it. It resembles the stock-matching activity and lacks social decisions. Treat these numbers and mechanics as prototype tuning, not final design.

Make club work attractive without making every other activity pointless. Introduce guest context, progression or a different challenge before relying on timers. If timing is added, include a relaxed option. Give relationships and skills benefits beyond earning more cash.

Test whether a player can explain their immediate objective, name a character's personal goal, notice a remembered decision, and choose between two useful activities. Include low-cash recovery, missed appointments, cancellation, failed shifts, mid-story saves, older-save migration and exactly-once finale rewards. Then ask whether tomorrow feels different from today.

## Research references

- [Paris Nights Java review — Pocket Gamer](https://www.pocketgamer.com/paris-nights/review/).
- [Paris Nights — original Java designer Danny Godin](https://www.coroflot.com/godind/Paris-Nights-Gameloft-2008).
- [Paris Nights contemporary review — Game Over Online](https://www.game-over.net/reviews/hand/Paris_Nights.html).
- [New York Nights contemporary review — GameSpot](https://www.gamespot.com/reviews/new-york-nights-success-in-the-city-review/1900-6122065/).
- [New York Nights contemporary hands-on — GameSpot](https://www.gamespot.com/articles/new-york-nights-success-in-the-city-hands-on/1100-6117789/).
- [New York Nights game description — MobyGames](https://www.mobygames.com/game/25968/new-york-nights-success-in-the-city/).

Research supports the broad mechanics and premises described above. The proposed PH NIGHT episode, priorities, skills and architecture are our own recommendations.

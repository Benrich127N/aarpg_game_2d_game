project: Lagos Life Simulator  
type: roadmap  
engine: Godot 4.x  
status: in-progress  
tags:

● godot

● gamedev

● lagos-life

● roadmap

  

Lagos Life Simulator | Master Roadmap

> [!abstract] Project goal  
> Build a top down 2D Lagos life sim. First release target: one street, five NPCs, two jobs, two shops, one room, working needs, dialogue, and save/load.

Companion: [[02 - Step by Step Development Guide]]

Definition of done for the first playable build

Wake in rented room

Walk to street and talk to NPC

Accept and complete a job

Receive pay exactly once

Buy and consume food

Return home and sleep

Save, quit, reopen, and continue

> [!important] Scope rule  
> Finish the first complete day before expanding into multiple districts, romance, vehicles, or businesses.

Progress dashboard

| Stage                            | Status        | Deliverable |     |
| -------------------------------- | ------------- | ----------- | --- |
| 00 Planning and Scope            | ⬜ Not started | 7 tasks     |     |
| 01 Godot Foundations             | ⬜ Not started | 8 tasks     |     |
| 02 Player and Camera             | ⬜ Not started | 7 tasks     |     |
| 03 Core State and Time           | ⬜ Not started | 8 tasks     |     |
| 04 HUD and Menus                 | ⬜ Not started | 6 tasks     |     |
| 05 Interaction                   | ⬜ Not started | 6 tasks     |     |
| 06 NPC and Dialogue              | ⬜ Not started | 7 tasks     |     |
| 07 Jobs and Minigames            | ⬜ Not started | 7 tasks     |     |
| 08 Inventory and Shops           | ⬜ Not started | 7 tasks     |     |
| 09 First Mainland Vertical Slice | ⬜ Not started | 7 tasks     |     |
| 10 Save and Load                 | ⬜ Not started | 7 tasks     |     |
| 11 Travel and Districts          | ⬜ Not started | 6 tasks     |     |
| 12 Progression and Economy       | ⬜ Not started | 6 tasks     |     |
| 13 Housing and Furniture         | ⬜ Not started | 6 tasks     |     |
| 14 Relationships and Quests      | ⬜ Not started | 6 tasks     |     |
| 15 Events and NPC Schedules      | ⬜ Not started | 6 tasks     |     |
| 16 Customization and Phone       | ⬜ Not started | 6 tasks     |     |
| 17 Audio and Polish              | ⬜ Not started | 6 tasks     |     |
| 18 QA Performance and Release    | ⬜ Not started | 7 tasks     |     |

Full task checklist

00 · Planning and Scope

Detailed instructions: [[02 - Step by Step Development Guide#Step 1 — Planning and Scope]]

Define core fantasy and target player

Choose top down 2D art direction and tile scale

Write one page game design document

Define 12 week MVP and explicitly defer advanced features

Define success criteria for first playable loop

Choose input scheme and desktop target

Create asset licensing and attribution log

01 · Godot Foundations

Detailed instructions: [[02 - Step by Step Development Guide#Step 2 — Godot Foundations]]

Install Godot 4.x and create project

Configure 1280×720 viewport and stretch settings

Learn scenes nodes signals and groups

Learn GDScript typed variables functions arrays dictionaries

Learn CharacterBody2D Area2D and collisions

Learn TileMapLayer and TileSet

Learn custom Resource files and scene instantiation

Initialize Git and Godot .gitignore

02 · Player and Camera

Detailed instructions: [[02 - Step by Step Development Guide#Step 3 — Player and Camera]]

Create Player.tscn and Player.gd

Configure Input Map for WASD and interact

Create placeholder sprite and collision shape

Implement normalized four way movement

Add AnimatedSprite2D and idle walk animations

Add Camera2D and limits

Test wall collisions and diagonal movement

03 · Core State and Time

Detailed instructions: [[02 - Step by Step Development Guide#Step 4 — Core State and Time]]

Create Global.gd AutoLoad and stat signals

Store currency as integer naira or kobo

Implement safe cash credit and debit

Implement energy hunger health reputation clamps

Create TimeManager.gd AutoLoad and time_changed signal

Implement game minutes hours days and pause

Implement scheduled hunger decay and day rollover

Write tests for midnight and time advancement

04 · HUD and Menus

Detailed instructions: [[02 - Step by Step Development Guide#Step 5 — HUD and Menus]]

Create HUD.tscn and HUD.gd

Add cash energy hunger health and time widgets

Connect signals without per frame polling

Add interaction prompt and notification toast

Create pause menu and settings placeholders

Test HUD across different window sizes

05 · Interaction

Detailed instructions: [[02 - Step by Step Development Guide#Step 6 — Interaction]]

Create reusable interactable contract

Add player interaction detection Area2D

Create proximity prompt and interact input

Create door bed NPC and shop test objects

Prevent interactions while dialogue or menu is open

Test overlapping interactables and priority

06 · NPC and Dialogue

Detailed instructions: [[02 - Step by Step Development Guide#Step 7 — NPC and Dialogue]]

Create NPC.tscn and reusable NPC.gd

Define NPC identities and dialogue data

Create DialogueUI.tscn and DialogueManager.gd

Implement branching choices and end dialogue

Implement dialogue conditions and effects

Track per NPC conversation flags

Create five NPCs and test all branches

07 · Jobs and Minigames

Detailed instructions: [[02 - Step by Step Development Guide#Step 8 — Jobs and Minigames]]

Create JobData Resource and JobManager.gd

Define eligibility pay energy cost and cooldown

Build delivery minigame

Build matching or office minigame

Validate success and failure results

Credit rewards exactly once

Add job unlocks and progress tracking

08 · Inventory and Shops

Detailed instructions: [[02 - Step by Step Development Guide#Step 9 — Inventory and Shops]]

Create ItemData Resource and item catalog

Create InventoryManager.gd and inventory UI

Implement stack limits add remove and use

Create Shop.tscn and shop UI

Implement atomic purchase validation

Implement food hunger restoration

Test insufficient funds and full inventory

09 · First Mainland Vertical Slice

Detailed instructions: [[02 - Step by Step Development Guide#Step 10 — First Mainland Vertical Slice]]

Create Mainland.tscn with TileMapLayer ground and obstacles

Build room market food shop job location and street

Add collisions and player spawn

Place five NPCs and interactive objects

Add street ambience and simple day night tint

Finish wake work shop eat sleep loop

Playtest a full game day without editor intervention

10 · Save and Load

Detailed instructions: [[02 - Step by Step Development Guide#Step 11 — Save and Load]]

Create SaveManager.gd and versioned JSON schema

Save stats clock location inventory and quest flags

Write save files to user:// with temp file strategy

Load saved state and restore correct spawn

Handle missing corrupt and older save versions

Add manual save and autosave triggers

Test saving after travel and restart

11 · Travel and Districts

Detailed instructions: [[02 - Step by Step Development Guide#Step 12 — Travel and Districts]]

Create SceneManager.gd and spawn markers

Implement scene transition and transport cost

Add business district prototype

Add Lekki and Island prototype

Preserve player and world state across travel

Implement travel time and loading feedback

12 · Progression and Economy

Detailed instructions: [[02 - Step by Step Development Guide#Step 13 — Progression and Economy]]

Separate cash net worth and reputation

Create SocialClassManager and unlock conditions

Implement career progression and achievements

Create balancing table for jobs and expenses

Add recurring rent and travel costs

Prevent exploit loops and unreasonable progression

13 · Housing and Furniture

Detailed instructions: [[02 - Step by Step Development Guide#Step 14 — Housing and Furniture]]

Create PropertyData and HousingManager

Implement renting and buying

Implement bed sleep and rent due dates

Create apartment interiors and furniture inventory

Add furniture placement and storage

Save furniture layout and ownership

14 · Relationships and Quests

Detailed instructions: [[02 - Step by Step Development Guide#Step 15 — Relationships and Quests]]

Create RelationshipManager and per NPC values

Implement friendship trust and optional romance

Create QuestData and QuestManager

Implement objectives rewards and prerequisites

Create quest journal and phone contacts

Test persistence and quest dependency chains

15 · Events and NPC Schedules

Detailed instructions: [[02 - Step by Step Development Guide#Step 16 — Events and NPC Schedules]]

Create EventManager and eligibility rules

Add rain traffic and chance encounters

Implement event cooldowns and choices

Create NPC daily schedule data

Implement NavigationAgent2D for local movement

Use lightweight offscreen NPC simulation

16 · Customization and Phone

Detailed instructions: [[02 - Step by Step Development Guide#Step 17 — Customization and Phone]]

Build layered player sprite clothing system

Create clothing inventory and shop

Create character customization menu

Build PhoneUI with bank contacts jobs map quests

Persist outfit and phone state

Test layer alignment in all movement directions

17 · Audio and Polish

Detailed instructions: [[02 - Step by Step Development Guide#Step 18 — Audio and Polish]]

Add original or licensed Nigerian inspired music

Add market traffic rain and room ambience

Add SFX buses footsteps and UI

Add day night lighting and streetlights

Improve dialogue feedback animations and accessibility

Add asset credits and audio controls

18 · QA Performance and Release

Detailed instructions: [[02 - Step by Step Development Guide#Step 19 — QA Performance and Release]]

Test all transactions and save edge cases

Profile memory FPS and scene load times

Test gamepad and keyboard controls

Add title screen settings credits and pause

Export Windows build and test outside editor

Package release and collect tester feedback

Fix blockers and prepare first release

Suggested checkpoints

Week 2: player movement and collision

Week 4: stats, clock, HUD

Week 6: interact and converse

Week 8: earn money through minigame

Week 10: first street, shop and needs loop

Week 12: stable saved vertical slice

Later: expansion, polish, release

Backlog / ideas (not MVP)

Driving and traffic AI

Business ownership and investments

Marriage and family systems

Multiple districts and luxury properties

Advanced weather and crowds

Android touch controls

Weekly retrospective template

● Week:

● Completed:

● Blocked by:

● Next smallest playable improvement:

● Bugs discovered:
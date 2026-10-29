project: PH NIGHT  
type: implementation-guide  
engine: Godot 4.x  
status: in-progress  
tags:

● godot

● gdscript

● implementation

  

PH NIGHT | Step by Step Development Guide

Tracker: [[01 - Master Development Roadmap]]

> [!tip] How to use  
> Complete steps in order. For each step, create the listed files, follow the editor actions, test the acceptance criteria, and then check it off in the master roadmap. Paths are proposed conventions; `user://` is runtime save storage, not a `res://` project folder.

Shared project layout

res://

├── assets/

│   ├── characters/ buildings/ vehicles/ environments/

│   ├── items/ animations/ audio/ fonts/

├── scenes/

│   ├── main/ player/ npc/ world/ buildings/

│   ├── shops/ jobs/ minigames/ ui/

├── scripts/

│   ├── autoload/ player/ npc/ world/

│   ├── economy/ dialogue/ inventory/ jobs/

│   ├── relationships/ ui/ save/

├── resources/

│   ├── items/ jobs/ dialogue/ characters/ properties/

├── data/

└── project.godot

> [!warning] Consistency  
> Use the same exact node names as the scripts reference. Create each folder before saving into it. Only register long-lived managers as AutoLoads; prefer signals, Resources, and scene-local nodes elsewhere.

Implementation sequence

Step 1 — Planning and Scope

> [!info] Objective  
> Planning and Scope: complete the tasks below before proceeding.

Files and exact locations

● res://docs/GDD.md

● res://assets/

In the Godot editor

Write down the player fantasy, game loop, MVP, art style, controls, and deferred features in the GDD. Keep every feature tied to a player action.

Implementation checklist

Define core fantasy and target player

Choose top down 2D art direction and tile scale

Write one page game design document

Define 12 week MVP and explicitly defer advanced features

Define success criteria for first playable loop

Choose input scheme and desktop target

Create asset licensing and attribution log

Acceptance test

You can describe the first 10 minutes of play without mentioning any unbuilt system.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 2 — Godot Foundations

> [!info] Objective  
> Godot Foundations: complete the tasks below before proceeding.

Files and exact locations

● res://project.godot

● res://.gitignore

In the Godot editor

Install Godot 4.x. Create a 2D project. Set viewport to 1280×720 and stretch mode to canvas_items. Learn the Inspector, Scene dock, FileSystem, Input Map, and Debugger. Initialize a Git repository.

Implementation checklist

Install Godot 4.x and create project

Configure 1280×720 viewport and stretch settings

Learn scenes nodes signals and groups

Learn GDScript typed variables functions arrays dictionaries

Learn CharacterBody2D Area2D and collisions

Learn TileMapLayer and TileSet

Learn custom Resource files and scene instantiation

Initialize Git and Godot .gitignore

Acceptance test

Project launches, Git ignores .godot/, and a blank scene runs.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 3 — Player and Camera

> [!info] Objective  
> Player and Camera: complete the tasks below before proceeding.

Files and exact locations

● res://scenes/player/Player.tscn

● res://scripts/player/Player.gd

In the Godot editor

Scene → New Scene → Other Node → CharacterBody2D. Rename to Player. Add children as shown below. Save scene, attach Player.gd to root, create movement actions in Project → Project Settings → Input Map, and add a test floor with walls.

Node tree

Player (CharacterBody2D)

├── AnimatedSprite2D

├── CollisionShape2D

├── Camera2D

└── InteractionArea (Area2D)

    └── CollisionShape2D

Implementation checklist

Create Player.tscn and Player.gd

Configure Input Map for WASD and interact

Create placeholder sprite and collision shape

Implement normalized four way movement

Add AnimatedSprite2D and idle walk animations

Add Camera2D and limits

Test wall collisions and diagonal movement

Acceptance test

Player moves at consistent speed diagonally and cannot cross a wall.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 4 — Core State and Time

> [!info] Objective  
> Core State and Time: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/autoload/Global.gd

● res://scripts/autoload/TimeManager.gd

In the Godot editor

Create both .gd scripts in scripts/autoload. Open Project → Project Settings → Globals/AutoLoad and add Global and TimeManager by their exact names. Implement signals for changed stats and time. Do not put game-state values in HUD scripts.

Implementation checklist

Create Global.gd AutoLoad and stat signals

Store currency as integer naira or kobo

Implement safe cash credit and debit

Implement energy hunger health reputation clamps

Create TimeManager.gd AutoLoad and time_changed signal

Implement game minutes hours days and pause

Implement scheduled hunger decay and day rollover

Write tests for midnight and time advancement

Acceptance test

Cash never becomes negative through purchases; midnight increments day; stats signals fire.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 5 — HUD and Menus

> [!info] Objective  
> HUD and Menus: complete the tasks below before proceeding.

Files and exact locations

● res://scenes/ui/HUD.tscn

● res://scripts/ui/HUD.gd

In the Godot editor

Scene → New Scene → Other Node → CanvasLayer. Rename to HUD. Build the exact node tree below, save as HUD.tscn, attach HUD.gd to root. Instance HUD.tscn into Main.tscn and connect to Global.stats_changed and TimeManager.time_changed.

Node tree

HUD (CanvasLayer)

└── MainUI (Control)

    ├── StatsPanel (PanelContainer)

    │   └── VBoxContainer

    │       ├── CashLabel (Label)

    │       ├── EnergyBar (ProgressBar)

    │       ├── HungerBar (ProgressBar)

    │       └── HealthBar (ProgressBar)

    ├── TimePanel (PanelContainer)

    │   └── TimeLabel (Label)

    └── QuickActions (Control)

Implementation checklist

Create HUD.tscn and HUD.gd

Add cash energy hunger health and time widgets

Connect signals without per frame polling

Add interaction prompt and notification toast

Create pause menu and settings placeholders

Test HUD across different window sizes

Acceptance test

Cash, needs, and time update without manually refreshing the scene; HUD remains fixed while camera moves.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 6 — Interaction

> [!info] Objective  
> Interaction: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/player/InteractionDetector.gd

● res://scripts/world/Interactable.gd

In the Godot editor

Add Area2D under Player with CollisionShape2D. Configure its collision mask to detect interactables. Create a base interact() contract, show a prompt for nearby targets, and call interact() only on the chosen target when the input action fires.

Implementation checklist

Create reusable interactable contract

Add player interaction detection Area2D

Create proximity prompt and interact input

Create door bed NPC and shop test objects

Prevent interactions while dialogue or menu is open

Test overlapping interactables and priority

Acceptance test

Press E near a bed or NPC and only that object responds.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 7 — NPC and Dialogue

> [!info] Objective  
> NPC and Dialogue: complete the tasks below before proceeding.

Files and exact locations

● res://scenes/npc/NPC.tscn

● res://scripts/npc/NPC.gd

● res://scenes/ui/DialogueUI.tscn

● res://scripts/dialogue/DialogueManager.gd

In the Godot editor

Create NPC.tscn and attach NPC.gd. Build DialogueUI as a Control based scene under a CanvasLayer. Store dialogue branches in Resources or JSON. On interaction, open dialogue, pause player input, and resolve selected choices through DialogueManager.

Node tree

NPC (CharacterBody2D)

├── AnimatedSprite2D

├── CollisionShape2D

├── NavigationAgent2D

└── InteractionArea (Area2D)

    └── CollisionShape2D

Implementation checklist

Create NPC.tscn and reusable NPC.gd

Define NPC identities and dialogue data

Create DialogueUI.tscn and DialogueManager.gd

Implement branching choices and end dialogue

Implement dialogue conditions and effects

Track per NPC conversation flags

Create five NPCs and test all branches

Acceptance test

An NPC offers two choices; the selected branch changes a persistent flag.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 8 — Jobs and Minigames

> [!info] Objective  
> Jobs and Minigames: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/jobs/JobManager.gd

● res://resources/jobs/JobData.gd

● res://scenes/minigames/DeliveryMinigame.tscn

In the Godot editor

Create JobData as a Resource type. Add a job manager that validates requirements. Build a standalone DeliveryMinigame scene. Emit a result when finished; let JobManager validate and pay once rather than letting the minigame edit cash directly.

Implementation checklist

Create JobData Resource and JobManager.gd

Define eligibility pay energy cost and cooldown

Build delivery minigame

Build matching or office minigame

Validate success and failure results

Credit rewards exactly once

Add job unlocks and progress tracking

Acceptance test

Winning awards correct pay once; losing does not award pay; energy cost is applied.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 9 — Inventory and Shops

> [!info] Objective  
> Inventory and Shops: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/inventory/InventoryManager.gd

● res://resources/items/ItemData.gd

● res://scenes/shops/Shop.tscn

In the Godot editor

Define ItemData with ID, price, category, stack limit, and effects. Build an inventory model before UI. Create shop listing UI and a transaction method that checks funds and capacity before committing purchase.

Implementation checklist

Create ItemData Resource and item catalog

Create InventoryManager.gd and inventory UI

Implement stack limits add remove and use

Create Shop.tscn and shop UI

Implement atomic purchase validation

Implement food hunger restoration

Test insufficient funds and full inventory

Acceptance test

Buying a Gala deducts cash, adds one item, and consuming it restores hunger.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 10 — First Mainland Vertical Slice

> [!info] Objective  
> First Mainland Vertical Slice: complete the tasks below before proceeding.

Files and exact locations

● res://scenes/world/mainland/Mainland.tscn

● res://scenes/main/Main.tscn

In the Godot editor

Create a Mainland scene with TileMapLayer ground, road, and obstacles. Add a room, shop, job station, and five NPCs. Create Main.tscn as the entry scene and instance the player, Mainland, and HUD. Test the full daily loop.

Node tree

Mainland (Node2D)

├── Ground (TileMapLayer)

├── Roads (TileMapLayer)

├── Obstacles (TileMapLayer)

├── Buildings (Node2D)

├── NPCs (Node2D)

└── PlayerSpawn (Marker2D)

Implementation checklist

Create Mainland.tscn with TileMapLayer ground and obstacles

Build room market food shop job location and street

Add collisions and player spawn

Place five NPCs and interactive objects

Add street ambience and simple day night tint

Finish wake work shop eat sleep loop

Playtest a full game day without editor intervention

Acceptance test

A tester can complete the wake → work → shop → eat → sleep loop.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 11 — Save and Load

> [!info] Objective  
> Save and Load: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/autoload/SaveManager.gd

● user://saves/slot_1.json

In the Godot editor

Create SaveManager as an AutoLoad. Serialize only data (not nodes) to a versioned dictionary. Write to user://saves, load on startup, validate keys and defaults, and restore player at a saved spawn or position.

Implementation checklist

Create SaveManager.gd and versioned JSON schema

Save stats clock location inventory and quest flags

Write save files to user:// with temp file strategy

Load saved state and restore correct spawn

Handle missing corrupt and older save versions

Add manual save and autosave triggers

Test saving after travel and restart

Acceptance test

Save, close game, reopen, and verify stats, inventory, location, and quest state.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 12 — Travel and Districts

> [!info] Objective  
> Travel and Districts: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/autoload/SceneManager.gd

● res://scenes/world/business_district/BusinessDistrict.tscn

In the Godot editor

Create SceneManager AutoLoad. Put named Marker2D spawn locations in each district. Travel should validate fare, change the scene, then place player at destination spawn and advance the clock.

Implementation checklist

Create SceneManager.gd and spawn markers

Implement scene transition and transport cost

Add business district prototype

Add Lekki and Island prototype

Preserve player and world state across travel

Implement travel time and loading feedback

Acceptance test

Travel to another district and back without duplicate players or lost data.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 13 — Progression and Economy

> [!info] Objective  
> Progression and Economy: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/economy/SocialClassManager.gd

● res://data/economy_balance.csv

In the Godot editor

Define explicit thresholds for wealth, reputation, and career progress. Keep cash and net worth separate. Gate jobs and locations via checks, and balance earnings versus recurring costs.

Implementation checklist

Separate cash net worth and reputation

Create SocialClassManager and unlock conditions

Implement career progression and achievements

Create balancing table for jobs and expenses

Add recurring rent and travel costs

Prevent exploit loops and unreasonable progression

Acceptance test

Class changes only when all requirements are met and locks update correctly.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 14 — Housing and Furniture

> [!info] Objective  
> Housing and Furniture: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/economy/HousingManager.gd

● res://resources/properties/PropertyData.gd

In the Godot editor

Define properties as Resources. Build an apartment scene, rent due logic, sleep interaction, furniture placement, and persistent ownership records.

Implementation checklist

Create PropertyData and HousingManager

Implement renting and buying

Implement bed sleep and rent due dates

Create apartment interiors and furniture inventory

Add furniture placement and storage

Save furniture layout and ownership

Acceptance test

Rent and sleep work across day changes; furniture stays after reload.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 15 — Relationships and Quests

> [!info] Objective  
> Relationships and Quests: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/relationships/RelationshipManager.gd

● res://scripts/autoload/QuestManager.gd

In the Godot editor

Store relationship scores by stable NPC ID. Define quests with objective IDs and state transitions. Subscribe to events such as job_completed and item_purchased to advance quests.

Implementation checklist

Create RelationshipManager and per NPC values

Implement friendship trust and optional romance

Create QuestData and QuestManager

Implement objectives rewards and prerequisites

Create quest journal and phone contacts

Test persistence and quest dependency chains

Acceptance test

A quest and relationship value remain correct after save and load.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 16 — Events and NPC Schedules

> [!info] Objective  
> Events and NPC Schedules: complete the tasks below before proceeding.

Files and exact locations

● res://scripts/autoload/EventManager.gd

● res://resources/characters/NPCSchedule.gd

In the Godot editor

Define events with conditions, cooldown, weights, and consequences. NPC schedules choose destinations by game hour; NavigationAgent2D handles local path following.

Implementation checklist

Create EventManager and eligibility rules

Add rain traffic and chance encounters

Implement event cooldowns and choices

Create NPC daily schedule data

Implement NavigationAgent2D for local movement

Use lightweight offscreen NPC simulation

Acceptance test

NPC schedule changes at the expected time and random events respect cooldowns.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 17 — Customization and Phone

> [!info] Objective  
> Customization and Phone: complete the tasks below before proceeding.

Files and exact locations

● res://scenes/ui/PhoneUI.tscn

● res://scripts/ui/PhoneUI.gd

In the Godot editor

Use aligned layered sprites for body, hair, clothing, and shoes. Build PhoneUI as a menu that reads manager data, rather than owning game state.

Implementation checklist

Build layered player sprite clothing system

Create clothing inventory and shop

Create character customization menu

Build PhoneUI with bank contacts jobs map quests

Persist outfit and phone state

Test layer alignment in all movement directions

Acceptance test

Outfit persists across scenes and the phone shows correct balances.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 18 — Audio and Polish

> [!info] Objective  
> Audio and Polish: complete the tasks below before proceeding.

Files and exact locations

● res://assets/audio/

● res://assets/animations/

In the Godot editor

Add audio buses for Music, Ambience, and SFX. Use licensed assets, test looping, add day/night tint and streetlights, and check accessibility of text and contrast.

Implementation checklist

Add original or licensed Nigerian inspired music

Add market traffic rain and room ambience

Add SFX buses footsteps and UI

Add day night lighting and streetlights

Improve dialogue feedback animations and accessibility

Add asset credits and audio controls

Acceptance test

Sound and lighting follow settings and game time without stutters.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Step 19 — QA Performance and Release

> [!info] Objective  
> QA Performance and Release: complete the tasks below before proceeding.

Files and exact locations

● res://scenes/ui/MainMenu.tscn

● res://scenes/ui/SettingsMenu.tscn

In the Godot editor

Create export presets, test a Windows export on a clean machine, profile large scenes, test corrupted saves and economy exploits, and record tester issues.

Implementation checklist

Test all transactions and save edge cases

Profile memory FPS and scene load times

Test gamepad and keyboard controls

Add title screen settings credits and pause

Export Windows build and test outside editor

Package release and collect tester feedback

Fix blockers and prepare first release

Acceptance test

Export runs without editor, critical bugs are closed, and saves survive restart.

Done when

No blocking errors in Godot debugger

Commit the working milestone to Git

Update [[01 - Master Development Roadmap]]

  

Cross-system event contracts

|Event                                        |Emitted by     |Consumers                     |  
|---------------------------------------------|---------------|------------------------------|  
|`stats_changed`                              |Global         |HUD                           |  
|`time_changed`                               |TimeManager    |HUD, schedules, world lighting|  
|`job_completed(job_id, success)`             |JobManager     |QuestManager, notifications   |  
|`item_purchased(item_id, count)`             |ShopManager    |QuestManager                  |  
|`dialogue_choice_selected(npc_id, choice_id)`|DialogueManager|Quests, relationships         |

Common mistakes to avoid

Avoid % ,.2f style formatting in GDScript; implement an explicit currency formatter.

Do not connect HUD to an unnamed dynamically created Timer node; connect to a public signal.

Do not keep authoritative money in UI or NPC scripts.

Do not make all NPCs run expensive logic every frame.

Do not assume a save file exists; validate and default missing fields.

Do not scale scope before a complete daily gameplay loop works.

Definition of done for MVP

One complete day is playable from a fresh save.

Two jobs and two shops function.

Five NPCs can be interacted with.

Time, hunger, energy, money, and inventory persist.

A Windows build works outside Godot.

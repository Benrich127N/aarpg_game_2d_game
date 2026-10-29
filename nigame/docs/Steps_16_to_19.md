# Steps 16–19 — release candidate

The remaining systems are implemented as a playable prototype. The Windows package is a local release candidate, not a public launch. Final external playtesting remains open.

## Events and schedules

`Game.events` owns timed rain/traffic/neighbour encounters, conditions, weighted selection, cooldowns and one-time choices. Outdoor daytime checks run at most once every three game hours. Rain and traffic affect the environment; traffic adds 20 minutes to bus travel. Helping a neighbour costs time/energy and awards reputation once. Open the phone with **Tab** or controller **Y** to answer an event. Event state and cooldowns persist in saves.

Five `NPCSchedule` Resources define work, lunch (12:00–14:00), and home (20:00–06:00) destinations. On Mainland, NavigationAgent2D follows a walkable corridor that avoids building walls. Dialogue freezes movement so the selected NPC stays nearby. Distant/unloaded NPCs use scheduled positions rather than running navigation; the phone map shows their current scheduled destinations. This is a local route prototype, not city-scale crowd simulation.

## Customization and phone

The player now uses original procedural **32×48** body, shirt, hair and shoe layers. All idle/walk frames and mirrored side movement share the same alignment. **O** opens the wardrobe, including a preview. The Mainland clothing stall sells three additional shirt colours; skin, hair and shoe options are free. Original third-party prototype artwork remains in the source tree for reference but is excluded from the Windows package.

The **Tab** phone includes bank transfers, contacts, jobs, map, quest journal, wardrobe and pending event choices. Cash and bank balance are separate; both count toward net worth. Invalid transfers and repeat clothing purchases change nothing. The last phone tab, owned/equipped clothes and character choices persist.

## Audio, lighting and accessibility

A cached AudioManager generates an original short pentatonic/percussion music loop, indoor/market/traffic/rain ambience, footsteps, UI clicks and bus sounds. There are no external recordings. Music, Ambience and SFX buses have independent saved sliders. Loop boundaries fade; explicit shutdown stops/relinquishes playback resources. This is prototype sound design, not a finished soundtrack.

Night tint and streetlights activate outside from 19:00 to 06:00. Rain has a visual overlay. **Settings**, available from title and pause, supports fullscreen, 100–140% text size and reduced motion. Reduced motion stops animated rain and camera smoothing. Controls remain visible; focus supports keyboard/controller menu navigation. Settings use `user://settings.cfg`, separate from the save slot.

## Saves and compatibility

The schema is now **version 3**. It extends the existing validated state with world events/NPC positions and character/phone/bank data. Version 1 and 2 saves migrate using deterministic defaults. Future versions, unknown assets/events, negative bank values and invalid outfits are rejected before mutation. The existing `NIGAME` user-data folder remains unchanged to preserve earlier saves.

The title screen provides Continue, a confirmed New game, Settings, Credits and Quit. Pause adds Save and return to title. The normal entry scene is `Scenes/ui/MainMenu.tscn`; `Scenes/main/Main.tscn` remains the gameplay scene used by integration tests.

## Rebuild and verify

The tested baseline is **Godot 4.4.1**, with the Compatibility renderer and a matching Windows x86_64 release template. Run these commands from the project directory in PowerShell:

```powershell
.\tools\test.ps1 -GodotExe 'C:\path\to\Godot_v4.4.1.exe'
.\tools\build.ps1 -GodotExe 'C:\path\to\Godot_v4.4.1.exe'
```

The build script fetches just the Windows release template from Godot's official 4.4.1 archive if missing, validates the ZIP member CRC, imports resources, runs all source tests, exports the game, runs standalone save/reopen checks, and packages the executable, PCK, README and engine licence notices. Templates and generated builds stay in ignored directories. No global template installation is required.

`tests/Steps16To19.tscn` covers schedule changes/navigation, event eligibility/rewards/cooldowns, bank accounting, clothing purchases/equipment, aligned layers, phone tabs, audio buses/settings, reduced motion, streetlights, save validation and migration. Earlier movement, daily-loop and independent-process persistence tests are retained. Controller mappings are checked with synthetic events; a physical controller still needs hands-on testing.

The exported executable includes explicit `--smoke-write` / `--smoke-read` QA modes. They exercise the daily loop and save restoration without the editor and write only into the build's `qa/` folder, never the player's save slot. Rendered QA reports capture frame rate and scene-load times; release builds may report zero for unavailable debug memory counters, so process memory is measured separately. Screenshots in `.godot/review-*.png` cover the title, phone, wardrobe, settings and rain/night view. See [release QA](Release_QA.md) for measured results and review limits.

## Remaining release gates

- Run the ZIP on a separate clean Windows machine and verify its graphics/audio drivers and permissions.
- Test a physical controller and listen to the sound mix on real speakers/headphones.
- Complete a human full-day playtest and review progression/rent/job pacing and all panels at smaller resolutions.
- Collect tester feedback using [the feedback template](Tester_Feedback.md), then fix confirmed blockers before a public release.

No publication or Git staging/commit was attempted. The earlier declined staging request remains respected.

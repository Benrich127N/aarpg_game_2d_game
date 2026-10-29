# Steps 3–5: player, state, and HUD

Run the project with F5. Move using WASD or arrow keys. The test world has solid boundary walls and an obstacle east of the starting position. The camera follows within the 1920×1080 world. The existing prototype sprite supplies down, up, and side idle/walk animations; its licensing status is still recorded in the asset log.

Press Escape to pause movement and time. Resume using Escape or the Resume button. Settings opens a placeholder panel. The HUD stays on screen while the camera moves, updates cash, energy, hunger, health, and time through signals, and exposes `notify(message)` and `set_interaction_prompt(text)` for later systems. The previous free-money button has been removed.

E is mapped and an interaction detection area is prepared on collision mask 2. Target selection and real interactions are Step 6; the current controls hint does not imply an interactable is already present.

## State contracts

- `Global` owns integer-naira cash, needs, reputation, and the prototype inventory. `add_cash` and `spend_cash` reject nonpositive amounts; spending also rejects insufficient funds, and credits reject integer overflow. They return success/failure and emit `stats_changed` only for accepted transactions. Needs/reputation change methods clamp values to 0–100.
- `TimeManager` owns day/hour/minute and emits `time_changed` plus `day_changed(day)`. New games start at day 1, 07:00. One real second advances one game minute. Every four-hour boundary removes 10 hunger satisfaction, including midnight. `advance_minutes` supports elapsed-time jumps and rejects nonpositive values. `clock_paused` stops automatic advancement; explicit advancement remains available for future sleep and job actions. Scene-tree pause stops both movement and automatic time.
- The early social-class prototype was removed from Global; it belongs to the later progression milestone. The unused root-level `Player.gd` remains untouched; the active scene uses `Scenes/Player.gd`.
- Existing `Scenes/` and `UI/` paths are retained so current references remain valid; these fulfil the guide's proposed player and HUD paths.

## Verification

Run `res://tests/Steps3To5.tscn` with F6, or run Godot with `--headless --path . res://tests/Steps3To5.tscn`. It prints PASS or reports failures and exits. Tests cover rejected and valid transactions, overflow, stat clamps, midnight, multi-day advancement, time signals, HUD updates, diagonal speed, wall blocking, pause behaviour, and HUD width at three window sizes. Tests use an isolated process and do not write player saves.

Headless tests and main-scene startup passed with Godot 4.4.1. Manual checks remain: walk in all directions and inspect sprite frames, follow the camera to each edge, inspect text/bars at different window sizes, and use the Settings and Resume buttons. Headless layout checks do not replace these visual/input checks. No commit was attempted because Git staging was declined earlier.

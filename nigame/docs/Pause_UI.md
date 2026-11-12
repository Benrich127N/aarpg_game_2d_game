# Pixel pause menu

`scripts/ui/PauseMenu.gd` presents a room vignette, current day/time/location/cash, framed options and a gold Resume button. The furniture reuses the recorded prop atlas. `MenuPageArt.gd` supplies the pause-specific “The street can wait” illustration. A darkened game view stays behind the menu.

All existing actions remain: Resume, Settings, Credits, Save game, Load saved game, New game, and Save & return to title. Settings and Credits return to the paused game and restore keyboard focus to Resume. Save success/failure feedback appears inside the pause panel. The content scrolls to keep focused options visible at larger text sizes.

The HUD still owns the actual tree pause state, keeping movement and the game clock stopped. The normal gameplay controls hide while paused. No new audio, fonts or third-party art were added.

`tests/PauseMenu.tscn` covers the illustrated page, session details, all seven actions being available, frozen gameplay/time, Settings/Credits transitions, isolated saving, large-text focus scrolling and resuming. It runs in `tools/test.ps1`.

# Illustrated settings

Settings uses the illustrated pixel-art layout from both the title screen and pause menu. The desk, plant and generator are reused from the recorded prop atlas. Native pixel icons distinguish three tabs:

- **Audio:** music, ambience and sound-effect sliders, live percentages and a footstep preview.
- **Display:** explicit 100/120/140% text-size choices, reduced-motion On/Off and fullscreen On/Off. Gold indicates the saved choice.
- **Controls:** framed keyboard keycaps and controller guidance.

Opening Settings starts on Audio. Switching tabs and changing display options retains keyboard focus. Preferences continue to use `SettingsManager.gd` and its existing saved configuration; no separate settings storage was introduced. Large text scrolls within the content panel. Closing returns to the title screen or existing pause menu, depending on where Settings was opened.

All new music, ambience, effect, display and keyboard glyphs are original code-drawn patterns in `UI/ControlGlyph.gd`; no external art/font dependency was added.

`tests/SettingsTabs.tscn` checks pause-menu styling, all three tabs, live percentages, text sizing, reduced motion, saved configuration, keyboard focus, fullscreen in headless mode, preview behaviour and smaller-window layout. `tests/TitleMenu.tscn` also checks the title-screen entry. Both run in `tools/test.ps1`.

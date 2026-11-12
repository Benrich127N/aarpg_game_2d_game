# Pixel controls and selectable options

The gameplay footer now contains four clickable controls: **E Interact**, **I Bag**, **Tab Phone**, and **Esc Menu**. `UI/ControlHintButton.gd` builds native buttons with raised square borders, keycaps, and original pixel glyphs from `UI/ControlGlyph.gd`. Existing keyboard/controller bindings remain in place.

Interact is disabled when there is no target. A nearby NPC or object displays a framed contextual caption above the controls. Clicking Interact uses the same interaction detector priority and range checks as the keyboard. Bag, Phone and Menu open their existing inventory, phone and pause interfaces. The dock hides during dialogue and pause, and click actions are blocked while another modal is open.

`PixelMenuTheme.decorate()` adds a pixel selection arrow to the focused/hovered option, replacing its small inactive marker. It is shared by menu choices, dialogue replies and pause options; native button captions and disabled behaviour are preserved. Focus outlines and warm highlights make the selection visible through keyboard navigation as well as mouse hover.

The controls follow the text-size setting. `tests/HUDControls.tscn` checks contextual availability, all four click actions, dialogue suppression, pause/resume, focus indicators, and layout at 140% text size in a 960 × 540 window. The test is part of `tools/test.ps1`.

# Room interior styling

`scripts/world/RoomInterior.gd` replaces the room's prototype tile visuals with retained native pixel drawing: staggered plank flooring, plaster walls and skirting, curtained windows, a framed print, books, a woven rug, a bedside lamp/table, storage trunk and a doormat/threshold. Windows and daylight patches respond to the clock. The apartment also has a tiled courtyard nook with a plant and chair.

Existing generated bed, desk, chair and plant sprites are reused. Room furniture is displayed at more useful sizes, and floating object labels are hidden; the contextual interaction dock still names nearby objects. The invisible exit Area2D retains its collision/interaction shape, with the drawn threshold identifying it visually.

The original wall TileMapLayer still provides collision and the same doorway gap. Its placeholder drawing is hidden. Bed, housing, furniture and exit positions remain compatible with the existing daily loop and saved furniture coordinates. The additional trunk, lamp and rug are decorative visuals.

`Main.gd` uses a steady room camera centred on the interior and returns to the normal following camera on leaving. Apartment upgrades recalculate the room framing. Saving formats and housing prices/ownership are unchanged.

`tests/RoomInterior.tscn` checks the visual/collision split, camera framing, walking routes, bed interaction, wall collision, exit/re-entry, placed furniture, apartment bounds and camera restoration. It captures room, apartment and night views in rendered mode. The test is included in `tools/test.ps1`.

# PH Night Club

The club is a separate scene at `Scenes/world/club/Club.tscn`. On the mainland, walk to the purple PH Night Club entrance in the south-east (1280, 880) and press E. Entry is free. Press E at the exit mat to return to the street outside the club.

Walk up to the bar and press E to start a bar shift. Serve the three requested drinks correctly to earn ₦1,500 and reputation. A shift costs 20 energy, advances time by 60 minutes, and has a 180-minute cooldown after the shift. Wrong orders or cancellation award no pay. There is no career prerequisite. Active shifts can be saved and resumed, and must be completed or cancelled before leaving.

The window preserves the 1280×720 layout when resized and starts at 1152×648. Street cameras include margins for the full character and HUD at map edges. Interiors use fixed cameras and solid boundaries; old saves outside an interior recover at its spawn.

Run `tests/ClubAndFraming.tscn` for edge framing, doorway travel, room threshold collision, shift payment, cooldown, and save validation checks. The case is also included in `tools/test.ps1`.

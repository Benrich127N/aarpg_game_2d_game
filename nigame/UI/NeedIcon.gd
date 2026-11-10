extends Control
## Small code-native pixel symbols remain sharp at every UI scale.
var kind: String = "Health"
var accent := Color("e99388")
const PIXELS := {
	"Health": ["01100110", "11111111", "11111111", "11111111", "01111110", "00111100", "00011000", "00000000"],
	"Hunger": ["00101000", "01010000", "00000000", "11111111", "11111111", "01111110", "00111100", "01111110"],
	"Energy": ["00011100", "00111000", "01110000", "11111110", "00011100", "00111000", "01110000", "01100000"],
}

func _init() -> void:
	custom_minimum_size = Vector2(36, 36)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var origin := (size - Vector2(24, 24)) * 0.5
	for y in range(8):
		for x in range(8):
			if PIXELS[kind][y][x] == "1":
				draw_rect(Rect2(origin + Vector2(x * 3, y * 3 + 2), Vector2(3, 3)), Color("101d1c"))
				draw_rect(Rect2(origin + Vector2(x * 3, y * 3), Vector2(3, 3)), accent)

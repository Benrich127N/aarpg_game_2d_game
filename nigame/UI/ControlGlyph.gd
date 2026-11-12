extends Control
var kind := "interact"
var color := Color("e6cf96")
const MASKS := {
	"music": ["00011110", "00010010", "00010010", "00010010", "00010010", "01110010", "11100110", "01100100"],
	"ambience": ["00010000", "00111000", "01111100", "00111000", "01111100", "11111110", "00010000", "00111000"],
	"effects": ["00010000", "01010100", "00111000", "11111110", "00111000", "01010100", "00010000", "00000000"],
	"display": ["11111111", "10000001", "10111101", "10111101", "10000001", "11111111", "00011000", "00111100"],
	"controls": ["00000000", "11111111", "10101011", "11010101", "10101011", "11000001", "11111111", "00000000"],
	"interact": ["01111110", "11000011", "10000001", "10101001", "10000001", "01111110", "00110000", "01100000"],
	"bag": ["00111100", "00100100", "01111110", "11000011", "11000011", "11011011", "11000011", "01111110"],
	"phone": ["00111100", "01100110", "01000010", "01000010", "01000010", "01000010", "01100110", "00111100"],
	"menu": ["00000000", "11111111", "11111111", "00000000", "11111111", "11111111", "00000000", "11111111"],
}

static func texture(kind: String, color: Color) -> Texture2D:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in range(8):
		for x in range(8):
			if MASKS[kind][y][x] == "1": image.fill_rect(Rect2i(x * 3, y * 3, 3, 3), color)
	return ImageTexture.create_from_image(image)

func _init() -> void:
	custom_minimum_size = Vector2(24, 24)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var origin := (size - Vector2(24, 24)) * 0.5
	for y in range(8):
		for x in range(8):
			if MASKS[kind][y][x] == "1":
				draw_rect(Rect2(origin + Vector2(x * 3, y * 3), Vector2(3, 3)), color)

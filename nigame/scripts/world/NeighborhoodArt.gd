extends Node2D
## Code-native pixel scenery on the same 32-pixel grid as the venue collisions.
var mode := "courtyard"

func _ready() -> void:
	z_index = -10 if mode != "street" else 0

func _draw() -> void:
	if mode == "street":
		_street()
		return
	var outside := Color("14231e") if mode == "courtyard" else Color("182321")
	draw_rect(Rect2(-4096, -4096, 10000, 10000), outside)
	draw_rect(Rect2(216, 184, 848, 432), Color("0c1814"))
	draw_rect(Rect2(224, 176, 832, 432), Color("b49a70"))
	draw_rect(Rect2(232, 184, 816, 8), Color("e3cf9e"))
	if mode == "courtyard": _courtyard()
	else: _shop()
	# Threshold is backed by a solid boundary; E performs scene travel.
	draw_rect(Rect2(608, 544, 64, 48), Color("735738"))
	draw_rect(Rect2(612, 548, 56, 36), Color("b99b67"))
	for x in [608, 668]: draw_rect(Rect2(x, 544, 4, 48), Color("e2ca91"))
	# Plaster caps and skirting echo the existing room architecture.
	for x in [224, 1024]:
		draw_rect(Rect2(x, 224, 4, 352), Color("d6c394"))
		draw_rect(Rect2(x + 24, 224, 8, 352), Color("8a6c48"))
	draw_rect(Rect2(256, 568, 352, 8), Color("8a6c48"))
	draw_rect(Rect2(672, 568, 352, 8), Color("8a6c48"))

func _courtyard() -> void:
	draw_rect(Rect2(256, 224, 768, 352), Color("769579"))
	for x in range(256, 1024, 32):
		for y in range(224, 576, 32):
			var grass := Color("73936e") if (x + y) % 64 else Color("789772")
			draw_rect(Rect2(x + 2, y + 2, 28, 28), grass)
			draw_rect(Rect2(x + 8, y + 10, 2, 6), Color("8ba47b"))
			draw_rect(Rect2(x + 12, y + 8, 2, 5), Color("63865f"))
	# Broad central and cross paths keep every activity reachable.
	draw_rect(Rect2(592, 224, 96, 352), Color("b5a37b"))
	draw_rect(Rect2(256, 368, 768, 64), Color("b5a37b"))
	for x in range(592, 688, 32):
		for y in range(224, 576, 32):
			draw_rect(Rect2(x + 2, y + 2, 28, 28), Color("d0bd93"))
	for x in [320, 800]:
		draw_rect(Rect2(x, 288, 160, 64), Color("735138"))
		draw_rect(Rect2(x + 8, 296, 144, 48), Color("493c2b"))
		for plant in range(5):
			var at := Vector2(x + 22 + plant * 28, 318)
			draw_rect(Rect2(at + Vector2(-2, 0), Vector2(4, 18)), Color("97af6e"))
			draw_rect(Rect2(at + Vector2(-10, -4), Vector2(10, 8)), Color("53794f"))
			draw_rect(Rect2(at + Vector2(2, -10), Vector2(10, 8)), Color("789a5d"))
			if plant % 2 == 0: draw_rect(Rect2(at + Vector2(-3, -12), Vector2(6, 6)), Color("e3b95d"))
	# Benches and community noticeboard.
	for x in [320, 864]:
		draw_rect(Rect2(x, 448, 96, 32), Color("795236"))
		for slat in range(3): draw_rect(Rect2(x + 4, 452 + slat * 8, 88, 5), Color("bc955e"))
		for leg in [x + 8, x + 80]: draw_rect(Rect2(leg, 480, 6, 8), Color("3c3125"))
	draw_rect(Rect2(604, 240, 72, 56), Color("654a34"))
	draw_rect(Rect2(608, 244, 64, 48), Color("e8d4a3"))
	draw_rect(Rect2(614, 252, 24, 28), Color("7bb3a7"))
	for line in range(4): draw_rect(Rect2(644, 252 + line * 7, 22, 2), Color("987046"))
	# Water barrel, paving and hanging community bunting.
	draw_rect(Rect2(960, 480, 40, 48), Color("467b7a"))
	draw_rect(Rect2(960, 484, 40, 6), Color("8eb7a4"))
	for x in range(280, 1000, 48):
		draw_rect(Rect2(x, 224, 24, 12), Color("c76c56") if x % 96 else Color("d4ab54"))

func _shop() -> void:
	for x in range(256, 1024, 32):
		for y in range(224, 576, 32):
			draw_rect(Rect2(x, y, 32, 32), Color("acaa8d") if (x + y) % 64 else Color("c5bfa0"))
	for shelf_x in [288, 544, 800]:
		draw_rect(Rect2(shelf_x, 256, 192, 64), Color("684e37"))
		for shelf in range(2):
			for item in range(8):
				var color: Color = [Color("ce7751"), Color("7bb3a7"), Color("e3b95d"), Color("eee1c2")][(item + shelf) % 4]
				draw_rect(Rect2(shelf_x + 8 + item * 22, 260 + shelf * 28, 14, 20), color)
			draw_rect(Rect2(shelf_x + 4, 282 + shelf * 28, 184, 5), Color("bc955e"))
	# The service counter and stock crates match the solid obstacle rectangles.
	draw_rect(Rect2(288, 416, 160, 64), Color("527b6a"))
	draw_rect(Rect2(284, 416, 168, 12), Color("d3bf8d"))
	draw_rect(Rect2(308, 398, 36, 18), Color("283d3c"))
	draw_rect(Rect2(312, 402, 24, 8), Color("8eb7a4"))
	for x in range(800, 896, 32):
		for y in range(416, 480, 32):
			draw_rect(Rect2(x + 1, y + 1, 30, 30), Color("a77e4e"))
			draw_rect(Rect2(x + 4, y + 4, 24, 24), Color("c9a16b"), false, 2)
			draw_rect(Rect2(x + 12, y + 8, 8, 16), Color("ead8a7"))
	draw_rect(Rect2(752, 328, 4, 176), Color("756f57"))
	for y in range(344, 504, 32): draw_rect(Rect2(750, y, 8, 12), Color("d4ab54"))
	draw_rect(Rect2(592, 476, 96, 60), Color("697b54"))
	for x in range(296, 440, 32):
		draw_rect(Rect2(x, 434, 24, 38), Color("426454"))
		draw_rect(Rect2(x + 2, 436, 20, 2), Color("7d9c79"))
	for x in range(800, 896, 32):
		for y in range(416, 480, 32):
			draw_line(Vector2(x + 5, y + 5), Vector2(x + 27, y + 27), Color("a77e4e"), 2)
	for x in range(598, 682, 8): draw_rect(Rect2(x, 482, 3, 48), Color("899064"))

func _street() -> void:
	# Courtyard gate, club frontage and outdoor cafe share the street map.
	draw_rect(Rect2(224, 832, 192, 112), Color("657b58"))
	for x in range(232, 416, 16): draw_rect(Rect2(x, 848, 8, 96), Color("bc955e"))
	draw_rect(Rect2(288, 848, 64, 96), Color("283d3c"))
	draw_rect(Rect2(284, 840, 72, 8), Color("e3cf9e"))
	draw_rect(Rect2(1184, 832, 192, 128), Color("34304b"))
	draw_rect(Rect2(1192, 840, 176, 4), Color("b778ce"))
	draw_rect(Rect2(1248, 856, 64, 104), Color("171724"))
	draw_rect(Rect2(1252, 860, 56, 96), Color("654d80"))
	draw_rect(Rect2(576, 784, 352, 208), Color("b5a37b"))
	for x in [608, 800]:
		draw_rect(Rect2(x, 800, 96, 64), Color("795236"))
		draw_rect(Rect2(x + 4, 804, 88, 52), Color("d3b675"))
		draw_rect(Rect2(x + 28, 816, 24, 16), Color("eee1c2"))
		draw_rect(Rect2(x + 34, 819, 12, 8), Color("ce7751"))
		for chair_x in [x, x + 64]:
			draw_rect(Rect2(chair_x, 880, 32, 24), Color("527b6a"))
			draw_rect(Rect2(chair_x, 880, 32, 5), Color("83b6a0"))
			for leg in [chair_x + 3, chair_x + 25]: draw_rect(Rect2(leg, 900, 4, 10), Color("795236"))
		for plank in range(4): draw_rect(Rect2(x + 8, 812 + plank * 10, 80, 1), Color("bc955e"))
	for x in [1196, 1328]:
		draw_rect(Rect2(x, 860, 32, 48), Color("171724"))
		draw_rect(Rect2(x + 4, 864, 24, 36), Color("8865a0"))
		draw_rect(Rect2(x + 14, 864, 2, 36), Color("b778ce"))
		draw_rect(Rect2(x + 4, 880, 24, 2), Color("b778ce"))
	for x in range(1196, 1360, 24):
		draw_rect(Rect2(x, 924, 20, 2), Color("5a466c"))
		draw_rect(Rect2(x + 8, 940, 20, 2), Color("5a466c"))

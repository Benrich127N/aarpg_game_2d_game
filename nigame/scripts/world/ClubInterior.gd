extends Node2D
## Static pixel architecture keeps the club readable without flashing effects.
func _ready() -> void:
	z_index = -10

func _draw() -> void:
	draw_rect(Rect2(-4096, -4096, 10000, 10000), Color("101421"))
	draw_rect(Rect2(224, 176, 832, 432), Color("34304b"))
	draw_rect(Rect2(256, 224, 768, 352), Color("201e32"))
	for x in range(256, 1024, 32):
		for y in range(224, 576, 32):
			draw_rect(Rect2(x + 1, y + 1, 30, 30), Color("302c46") if (x + y) % 64 else Color("28253b"))
	# Neon wall trim, bar counter, bottles and stools.
	draw_rect(Rect2(240, 188, 800, 4), Color("b778ce"))
	draw_rect(Rect2(320, 256, 288, 64), Color("775771"))
	draw_rect(Rect2(316, 256, 296, 12), Color("d4a778"))
	for x in range(336, 592, 32):
		draw_rect(Rect2(x, 236, 10, 20), Color("79b4a5"))
		draw_rect(Rect2(x + 2, 230, 6, 8), Color("d3bf8d"))
	for x in [352, 448, 544]:
		draw_rect(Rect2(x, 332, 24, 8), Color("aa6d9b"))
		draw_rect(Rect2(x + 10, 340, 4, 14), Color("151421"))
	# DJ booth and two speakers sit inside solid furniture tiles.
	draw_rect(Rect2(800, 256, 160, 96), Color("171724"))
	draw_rect(Rect2(824, 280, 112, 32), Color("56536e"))
	for x in [848, 912]: draw_circle(Vector2(x, 296), 12, Color("151421"))
	for x in [804, 940]:
		draw_rect(Rect2(x, 264, 16, 72), Color("090e19"))
		draw_circle(Vector2(x + 8, 318), 6, Color("8a699d"))
	# Dance floor and seating along the side walls.
	for x in range(512, 800, 48):
		for y in range(400, 496, 48):
			draw_rect(Rect2(x + 2, y + 2, 44, 44), [Color("654d80"), Color("437f83"), Color("a76b83")][posmod(x / 48 + y / 48, 3)])
	for x in [288, 912]:
		draw_rect(Rect2(x, 420, 72, 104), Color("614263"))
		draw_rect(Rect2(x + 8, 428, 56, 88), Color("916185"))
	draw_rect(Rect2(608, 544, 64, 48), Color("698c80"))
	draw_rect(Rect2(612, 548, 56, 36), Color("283d3c"))
	# Timber panels, stitched cushions and equipment details share the room's materials.
	for x in range(324, 608, 32):
		draw_rect(Rect2(x, 274, 26, 38), Color("634958"))
		draw_rect(Rect2(x + 2, 276, 22, 2), Color("9c7487"))
		draw_rect(Rect2(x + 4, 284, 2, 20), Color("775771"))
	for x in [288, 912]:
		for y in [432, 476]:
			draw_rect(Rect2(x + 12, y, 48, 36), Color("a47491"))
			draw_rect(Rect2(x + 16, y + 4, 40, 28), Color("916185"))
			draw_rect(Rect2(x + 16, y + 4, 40, 2), Color("be94ac"))
		for foot in [x + 8, x + 56]: draw_rect(Rect2(foot, 524, 6, 6), Color("795236"))
	for x in range(868, 900, 8):
		draw_rect(Rect2(x, 284, 4, 24), Color("272537"))
		draw_rect(Rect2(x, 288 + x % 3 * 4, 4, 4), Color("79b4a5"))
	for x in [276, 968]:
		draw_rect(Rect2(x, 364, 24, 24), Color("795236"))
		draw_rect(Rect2(x + 4, 346, 20, 20), Color("527b6a"))
		draw_rect(Rect2(x - 4, 354, 16, 12), Color("769579"))

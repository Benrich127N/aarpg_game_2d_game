extends Node2D
## Code-native pixel architecture, layered under the existing furniture and physics.
var right_wall := 21

func _ready() -> void:
	z_index = -10
	TimeManager.time_changed.connect(queue_redraw)

func camera_center() -> Vector2:
	return Vector2((160 + (right_wall + 1) * 32) * 0.5, 338)

func _draw() -> void:
	draw_rect(Rect2(-4096, -4096, 8192, 8192), Color("14231e"))
	var outer := Rect2(160, 160, (right_wall - 4) * 32, 416)
	var floor := Rect2i(192, 224, (right_wall - 6) * 32, 320)
	draw_rect(Rect2(outer.position + Vector2(-8, 8), outer.size + Vector2(16, 8)), Color("0c1814"))
	# Staggered boards replace the prototype's full-screen stripes.
	for row in range(20):
		for column in range(-1, ceili(floor.size.x / 64.0)):
			var start := Vector2i(192 + column * 64 + (32 if row % 2 else 0), 224 + row * 16)
			var board := Rect2i(start, Vector2i(64, 16)).intersection(floor)
			if not board.has_area(): continue
			var tone: Color = [Color("ac8052"), Color("b68b5b"), Color("b18a59"), Color("bb9160")][posmod(column * 3 + row * 7, 4)]
			draw_rect(Rect2(board), tone)
			draw_line(Vector2(board.position.x, board.end.y - 1), Vector2(board.end.x, board.end.y - 1), Color("91663f"), 1)
			draw_line(Vector2(board.position), Vector2(board.position.x, board.end.y), Color("987046"), 1)
			if board.size.x > 32:
				draw_rect(Rect2(board.position + Vector2i(10, 5), Vector2i(18, 1)), tone.lightened(0.06))
	# Plaster, timber caps and skirting keep the room's existing wall footprint.
	wall(Rect2(160, 160, outer.size.x, 64))
	wall(Rect2(160, 224, 32, 352))
	wall(Rect2(right_wall * 32, 224, 32, 352))
	wall(Rect2(160, 544, 256, 32))
	wall(Rect2(480, 544, right_wall * 32 - 448, 32))
	draw_rect(Rect2(192, 224, floor.size.x, 8), Color(0.16, 0.12, 0.08, 0.16))
	draw_rect(Rect2(192, 224, 6, 320), Color(0.16, 0.12, 0.08, 0.12))
	window(Vector2(352, 168), Vector2(56, 44))
	window(Vector2(544, 168), Vector2(56, 44))
	# Framed print above the bed and a small wall shelf of books.
	draw_rect(Rect2(256, 170, 32, 34), Color("654a34"))
	draw_rect(Rect2(260, 174, 24, 26), Color("e8d4a3"))
	draw_rect(Rect2(264, 180, 16, 12), Color("6b9277"))
	draw_rect(Rect2(270, 177, 6, 6), Color("ce9c52"))
	draw_rect(Rect2(436, 202, 64, 6), Color("6c4b32"))
	for i in range(6):
		draw_rect(Rect2(440 + i * 8, 184 + i % 2 * 3, 6, 18 - i % 2 * 3), [Color("b77554"), Color("638c7b"), Color("d3b675")][i % 3])
	rug(Rect2i(352, 368, 176, 112))
	bedside()
	# Storage trunk beside the plant, away from the doorway and main walkway.
	draw_rect(Rect2(232, 424, 64, 48), Color("5c412c"))
	draw_rect(Rect2(236, 428, 56, 38), Color("95683f"))
	draw_rect(Rect2(236, 428, 56, 8), Color("bc955e"))
	draw_rect(Rect2(258, 443, 12, 4), Color("e1bf76"))
	draw_rect(Rect2(240, 468, 6, 6), Color("3c3125"))
	draw_rect(Rect2(282, 468, 6, 6), Color("3c3125"))
	# An actual threshold and doormat replace the yellow prototype exit square.
	draw_rect(Rect2(416, 502, 64, 40), Color("334d3d"))
	draw_rect(Rect2(420, 506, 56, 32), Color("697b54"))
	for i in range(6): draw_rect(Rect2(424, 510 + i * 4, 48, 2), Color("b2a06b"))
	draw_rect(Rect2(416, 544, 64, 32), Color("735738"))
	draw_rect(Rect2(420, 548, 56, 24), Color("b99b67"))
	draw_rect(Rect2(416, 540, 4, 36), Color("e2ca91"))
	draw_rect(Rect2(476, 540, 4, 36), Color("e2ca91"))
	if right_wall > 21:
		wall(Rect2(672, 224, 32, 192))
		draw_rect(Rect2(704, 224, 160, 192), Color("697d64"))
		for x in range(704, 864, 32):
			for y in range(224, 416, 32):
				draw_rect(Rect2(x + 1, y + 1, 30, 30), Color("809075") if (x + y) % 64 else Color("74866c"))
		window(Vector2(744, 168), Vector2(64, 44))

func wall(rect: Rect2) -> void:
	draw_rect(rect, Color("c9b789"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 5)), Color("e3cf9e"))
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 8), Vector2(rect.size.x, 8)), Color("765a3c"))
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 10), Vector2(rect.size.x, 2)), Color("ad8d58"))

func window(at: Vector2, dimensions: Vector2) -> void:
	var night := TimeManager.current_hour >= 19 or TimeManager.current_hour < 6
	draw_rect(Rect2(at, dimensions), Color("5c4833"))
	draw_rect(Rect2(at + Vector2(4, 4), dimensions - Vector2(8, 8)), Color("304a5b") if night else Color("8db9b0"))
	draw_rect(Rect2(at + Vector2(4, dimensions.y - 14), Vector2(dimensions.x - 8, 10)), Color("506d68") if night else Color("b9cba2"))
	draw_rect(Rect2(at + Vector2(dimensions.x * 0.5 - 1, 4), Vector2(2, dimensions.y - 8)), Color("dcc69a"))
	draw_rect(Rect2(at + Vector2(4, dimensions.y * 0.5), Vector2(dimensions.x - 8, 2)), Color("dcc69a"))
	for side in [-1, 1]:
		var x: float = at.x - 8 if side == -1 else at.x + dimensions.x
		draw_rect(Rect2(x, at.y - 2, 8, dimensions.y + 4), Color("ae7056"))
		draw_rect(Rect2(x + 2, at.y, 2, dimensions.y), Color("d4936b"))
	draw_rect(Rect2(at + Vector2(-10, -5), Vector2(dimensions.x + 20, 3)), Color("5b4936"))
	if not night:
		draw_rect(Rect2(at.x + 8, 232, 32, 40), Color(1, 0.88, 0.61, 0.09))
		draw_rect(Rect2(at.x + 24, 272, 32, 24), Color(1, 0.88, 0.61, 0.06))

func rug(rect: Rect2i) -> void:
	draw_rect(Rect2(rect.position + Vector2i(2, 3), rect.size), Color(0.1, 0.08, 0.06, 0.2))
	draw_rect(Rect2(rect), Color("714839"))
	draw_rect(Rect2(rect.grow(-4)), Color("c19661"))
	draw_rect(Rect2(rect.grow(-8)), Color("506e5d"))
	for x in range(rect.position.x + 20, rect.end.x - 12, 24):
		for y in range(rect.position.y + 20, rect.end.y - 12, 24):
			draw_rect(Rect2(x - 4, y, 12, 4), Color("d3bd87"))
			draw_rect(Rect2(x, y - 4, 4, 12), Color("d3bd87"))
	for x in range(rect.position.x + 4, rect.end.x, 8):
		draw_rect(Rect2(x, rect.position.y - 3, 3, 3), Color("c7ae77"))
		draw_rect(Rect2(x, rect.end.y, 3, 3), Color("c7ae77"))

func bedside() -> void:
	draw_rect(Rect2(352, 272, 32, 20), Color("795236"))
	draw_rect(Rect2(350, 268, 36, 8), Color("c1955c"))
	draw_rect(Rect2(354, 292, 4, 10), Color("533d2a"))
	draw_rect(Rect2(378, 292, 4, 10), Color("533d2a"))
	draw_rect(Rect2(364, 252, 4, 16), Color("bc975e"))
	draw_rect(Rect2(356, 242, 20, 12), Color("eed8a4"))
	draw_rect(Rect2(360, 238, 12, 4), Color("eed8a4"))
	draw_rect(Rect2(358, 265, 16, 3), Color("dfbc77"))

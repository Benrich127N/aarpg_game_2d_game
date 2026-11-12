extends Node2D
## Original pixel architecture gives each district a recognizable destination.
var district_id := "business"

func _draw() -> void:
	match district_id:
		"business":
			building(Rect2(256, 192, 384, 224), Color("607c80"), 4)
			building(Rect2(768, 224, 384, 192), Color("45656d"), 6)
			for x in range(280, 624, 48):
				draw_rect(Rect2(x, 208, 32, 8), Color("d4ab54"))
			draw_rect(Rect2(384, 352, 128, 64), Color("213b43"))
			draw_rect(Rect2(444, 356, 4, 60), Color("a7c2bf"))
		"lekki":
			building(Rect2(256, 256, 384, 160), Color("e0cfaa"), 3)
			draw_rect(Rect2(240, 240, 416, 24), Color("aa6c50"))
			for x in range(248, 648, 16): draw_rect(Rect2(x, 240, 8, 24), Color("be805b"))
			building(Rect2(768, 288, 384, 128), Color("c9b789"), 4)
			for x in [280, 608, 800, 1120]: palm(Vector2(x, 412))
			for x in range(792, 1140, 24): draw_rect(Rect2(x, 380, 4, 36), Color("465d43"))
		"island":
			draw_rect(Rect2(224, 160, 1000, 256), Color("406f7b"))
			for y in range(176, 416, 24):
				for x in range(240, 1220, 64): draw_rect(Rect2(x + (16 if y % 48 else 0), y, 32, 2), Color("79a9ad"))
			building(Rect2(256, 240, 384, 176), Color("d2bca0"), 4)
			building(Rect2(768, 272, 384, 144), Color("bca58c"), 4)
			for x in range(224, 1232, 32):
				draw_rect(Rect2(x, 408, 24, 8), Color("bc955e"))
				draw_rect(Rect2(x + 8, 392, 4, 24), Color("735138"))
	# Shared pavement markings, with distinct architecture above it.
	for x in range(256, 1216, 64): draw_rect(Rect2(x, 428, 48, 2), Color("d0bd93"))

func building(rect: Rect2, tone: Color, columns: int) -> void:
	draw_rect(rect, tone.darkened(0.3))
	draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), tone)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 8)), tone.lightened(0.25))
	for row in range(3):
		for column in range(columns):
			var x := rect.position.x + 16 + column * (rect.size.x - 32) / columns
			var y := rect.position.y + 24 + row * (rect.size.y - 40) / 3
			draw_rect(Rect2(x, y, (rect.size.x - 32) / columns - 12, 28), Color("243f49"))
			draw_rect(Rect2(x + 3, y + 3, (rect.size.x - 32) / columns - 18, 8), Color("9fc3bc"))

func palm(at: Vector2) -> void:
	draw_rect(Rect2(at + Vector2(-4, -92), Vector2(8, 92)), Color("795236"))
	for y in range(-88, 0, 12): draw_rect(Rect2(at + Vector2(-4, y), Vector2(8, 3)), Color("bc955e"))
	for direction in [-1, 1]:
		for step in range(4):
			draw_rect(Rect2(at + Vector2(direction * step * 10 - 12, -108 + step * 6), Vector2(24, 10)), Color("467b5a") if step % 2 else Color("6b9466"))

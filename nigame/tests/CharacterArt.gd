extends Node
const ART = preload("res://scripts/characters/CharacterArt.gd")
const LAYERS = preload("res://scripts/characters/LayeredCharacter.gd")
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	for id in ART.SHEETS:
		var frames: SpriteFrames = ART.frames(id)
		for direction in ["down", "up", "side"]:
			check(frames.get_frame_count("idle_" + direction) == 1, id + " idle frame")
			check(frames.get_frame_count("walk_" + direction) == 4, id + " walk cycle")
		for frame in ART.cells(id):
			check(frame.get_size() == Vector2i(32, 48), id + " frame dimensions")
			check(frame.get_used_rect().get_area() > 200, id + " visible character")
			check(frame.get_pixel(0, 0).a == 0 and frame.get_pixel(31, 47).a == 0, id + " transparent corners")
	for part in ["body", "shirt", "hair", "shoes"]:
		var first := LAYERS.frames(part, Color("47856c")).get_frame_texture("idle_down", 0).get_image()
		var second := LAYERS.frames(part, Color("c76c56")).get_frame_texture("idle_down", 0).get_image()
		check(first.get_data() != second.get_data(), part + " wardrobe palette changes visible pixels")
		check(first.get_used_rect().get_area() > 0, part + " layer contains artwork")
		for y in range(48):
			for x in range(32):
				var count := 0
				for other in ["body", "shirt", "hair", "shoes"]:
					var image := LAYERS.frames(other, Color.WHITE).get_frame_texture("idle_down", 0).get_image()
					if image.get_pixel(x, y).a > 0: count += 1
				check(count <= 1, "Wardrobe layers do not overlap")
	print("CHARACTER ART: PASS" if failures == 0 else "CHARACTER ART: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

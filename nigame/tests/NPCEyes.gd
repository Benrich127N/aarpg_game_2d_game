extends Node
const ART = preload("res://scripts/characters/CharacterArt.gd")
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func eye_rows(image: Image, height: int) -> Dictionary:
	var counts := Vector2.ZERO
	var positions := Vector2.ZERO
	for y in range(height):
		for x in range(32):
			var color := image.get_pixel(x, y)
			if color.a > 0.7 and color.r > 0.65 and color.g > 0.65 and color.b > 0.65 and color.s < 0.25:
				if x < 16:
					counts.x += 1
					positions.x += y
				else:
					counts.y += 1
					positions.y += y
	return {"counts": counts, "y": positions / counts.max(Vector2.ONE)}

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.reset()
	TimeManager.clock_paused = true
	for id in Game.relationships.NPC_IDS:
		var frames := ART.frames(id)
		var height: int = ART.NPC_HEAD_HEIGHT[id]
		for direction in ["down", "up", "side"]:
			var idle := frames.get_frame_texture("idle_" + direction, 0).get_image()
			var reference := idle.get_region(Rect2i(0, 0, 32, height)).get_data()
			for step in range(4):
				var walking := frames.get_frame_texture("walk_" + direction, step).get_image()
				check(walking.get_region(Rect2i(0, 0, 32, height)).get_data() == reference, id + " head and eyes stay fixed through " + direction)
				if direction == "down":
					var eyes := eye_rows(walking, height)
					check(eyes.counts.x > 0 and eyes.counts.y > 0, id + " keeps both eyes visible")
					check(absf(eyes.y.x - eyes.y.y) <= 0.5, id + " eyes share a baseline")
				if direction == "side":
					var eyes := eye_rows(walking, height)
					check(eyes.counts.x + eyes.counts.y > 0, id + " keeps profile eye visible")
			var body_rect := Rect2i(0, height, 32, 48 - height)
			var contact := frames.get_frame_texture("walk_" + direction, 1).get_image()
			check(contact.get_region(body_rect).get_data() != idle.get_region(body_rect).get_data(), id + " body still walks in " + direction)
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	Game.scenes.travel("mainland", true)
	for tick in range(3): await get_tree().physics_frame
	for npc in get_tree().get_nodes_in_group("interactables"):
		if npc.kind != "npc": continue
		npc._update_animation(Vector2.LEFT, true)
		check(npc.sprite.flip_h and npc.sprite.animation == "walk_side", "NPC turns left")
		npc._update_animation(Vector2.DOWN, true)
		check(not npc.sprite.flip_h and npc.sprite.animation == "walk_down", "NPC front face clears inherited mirroring")
		npc._update_animation(Vector2.LEFT, true)
		npc._update_animation(Vector2.UP, true)
		check(not npc.sprite.flip_h and npc.sprite.animation == "walk_up", "NPC back face clears inherited mirroring")
		npc._update_animation(Vector2.RIGHT, true)
		npc._update_animation(Vector2.ZERO, false)
		check(not npc.sprite.flip_h and npc.sprite.animation == "idle_side", "Stopping preserves profile direction")
	print("NPC EYES: PASS" if failures == 0 else "NPC EYES: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

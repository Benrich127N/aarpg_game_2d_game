extends Node2D
const ART = preload("res://scripts/characters/CharacterArt.gd")
const LAYERS = preload("res://scripts/characters/LayeredCharacter.gd")
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func shoe_difference(frame: Image) -> float:
	var totals := Vector2.ZERO
	var counts := Vector2.ZERO
	for y in range(34, 48):
		for x in range(32):
			var pixel := frame.get_pixel(x, y)
			if pixel.a > 0.5 and pixel.r > pixel.g * 1.6 and pixel.r > pixel.b * 1.4:
				if x < 16:
					totals.x += y
					counts.x += 1
				else:
					totals.y += y
					counts.y += 1
	return totals.x / maxf(counts.x, 1) - totals.y / maxf(counts.y, 1)

func head_anchor(image: Image) -> Vector2:
	var left := 32
	var right := 0
	var top := 18
	for y in range(18):
		for x in range(32):
			if image.get_pixel(x, y).a >= 0.7:
				left = mini(left, x)
				right = maxi(right, x)
				top = mini(top, y)
	return Vector2((left + right) * 0.5, top)

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/walk-test-settings.cfg"
	Game.reset()
	TimeManager.clock_paused = true
	var cells := ART.player_cells()
	for row in range(2):
		check(shoe_difference(cells[row * 4 + 1]) * shoe_difference(cells[row * 4 + 3]) < 0, "Vertical cycle alternates leading foot")
		check(cells[row * 4].get_data() == cells[row * 4 + 2].get_data(), "Passing pose is stable between left and right steps")
		var anchor := head_anchor(cells[row * 4])
		for phase in [1, 3]:
			var head := head_anchor(cells[row * 4 + phase])
			check(head.y == anchor.y and absf(head.x - anchor.x) <= 0.5, "Head stays aligned through the vertical stride")
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	Game.scenes.travel("mainland", true)
	for frame in range(3): await get_tree().physics_frame
	var player: CharacterBody2D = Game.player
	for action in ["move_down", "move_up"]:
		player.position = Vector2(1248, 672)
		var visited := {}
		Input.action_press(action)
		for tick in range(75):
			await get_tree().physics_frame
			visited[player.sprite.frame] = true
			for layer in player.layers:
				check(layer.frame == player.sprite.frame and is_equal_approx(layer.frame_progress, player.sprite.frame_progress), "Wardrobe layers stay in phase")
		check(visited.size() == 4, "Vertical movement visits both steps and passing poses")
		check(player.sprite.animation == ("walk_down" if action == "move_down" else "walk_up"), "Correct vertical animation selected")
		Input.action_release(action)
		await get_tree().physics_frame
		await get_tree().physics_frame
		check(player.walk_distance == 0 and player.sprite.frame == 0, "Stopping returns to a stable standing pose")
	player.position = Vector2(1248, 1035)
	Input.action_press("move_down")
	for frame in range(30): await get_tree().physics_frame
	check(player.sprite.animation == "idle_down" and player.walk_distance == 0, "A blocked player does not walk in place")
	Input.action_release("move_down")
	print("PLAYER WALK: PASS" if failures == 0 else "PLAYER WALK: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

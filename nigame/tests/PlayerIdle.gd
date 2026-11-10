extends Node
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/idle-test-settings.cfg"
	Game.reset()
	Game.settings.set_value("reduced_motion", false)
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	await get_tree().physics_frame
	var player: CharacterBody2D = main.get_node("Player")
	var start := player.position
	await get_tree().create_timer(0.9).timeout
	check(player.sprite.scale.y != 2.0, "Standing player breathes")
	check(player.position == start, "Idle does not move player or collision body")
	for layer in player.layers:
		check(layer.scale == player.sprite.scale and layer.position == player.sprite.position, "Wardrobe layers stay aligned while breathing")
		check(is_equal_approx(layer.position.y + 22.0 * layer.scale.y, 22.0), "Feet remain planted")
	Input.action_press("move_left")
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(player.sprite.scale == Vector2(2, 2) and player.sprite.animation == "walk_side", "Walking clears idle deformation")
	Input.action_release("move_left")
	await get_tree().create_timer(0.9).timeout
	check(player.sprite.animation == "idle_side" and player.sprite.flip_h, "Idle preserves last facing direction")
	Game.settings.set_value("reduced_motion", true)
	check(player.sprite.scale == Vector2(2, 2), "Reduced motion resets idle immediately")
	await get_tree().create_timer(0.9).timeout
	check(player.sprite.scale == Vector2(2, 2), "Reduced motion keeps a still idle")
	Game.settings.set_value("reduced_motion", false)
	await get_tree().create_timer(0.9).timeout
	Game.open_modal()
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(player.sprite.scale == Vector2(2, 2), "Menus return the player to a neutral pose")
	Game.close_modal()
	print("PLAYER IDLE: PASS" if failures == 0 else "PLAYER IDLE: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

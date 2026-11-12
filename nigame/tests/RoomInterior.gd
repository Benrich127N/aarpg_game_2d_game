extends Node
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func settle() -> void:
	for frame in range(3): await get_tree().physics_frame

func target(kind: String) -> Area2D:
	for item in get_tree().get_nodes_in_group("interactables"):
		if item.kind == kind: return item
	return null

func walk_to(at: Vector2) -> void:
	for frame in range(150):
		for action in ["move_left", "move_right", "move_up", "move_down"]: Input.action_release(action)
		var offset: Vector2 = at - Game.player.position
		if offset.length() <= 5: break
		if absf(offset.x) > 4: Input.action_press("move_right" if offset.x > 0 else "move_left")
		if absf(offset.y) > 4: Input.action_press("move_down" if offset.y > 0 else "move_up")
		await get_tree().physics_frame
	for action in ["move_left", "move_right", "move_up", "move_down"]: Input.action_release(action)
	await settle()
	check(Game.player.position.distance_to(at) <= 7, "Room walking route stays clear")

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.godot/review-interior-" + name + ".png")

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/room-interior-settings.cfg"
	Game.reset()
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	await settle()
	var interior: Node2D = main.district.get_node("RoomInterior")
	var camera: Camera2D = Game.player.get_node("Camera2D")
	check(interior.right_wall == 21 and not main.district.ground.visible, "Starter room uses custom architecture")
	check(not main.district.obstacles.visible and main.district.obstacles.collision_enabled, "Prototype wall visuals hide while collision remains enabled")
	check(camera.top_level and camera.zoom == Vector2(1.125, 1.125), "Room camera frames the whole interior")
	var camera_before := camera.global_position
	await capture("room")
	await walk_to(Vector2(448, 336))
	await walk_to(Vector2(288, 336))
	check(camera.global_position == camera_before, "Room camera stays steady while walking")
	var detector: Area2D = Game.player.get_node("InteractionArea")
	check(detector.choose(detector.get_overlapping_areas()) == target("bed"), "Bed is reachable from the open walkway")
	target("bed").interact()
	check(Game.ui.heading.text == "Rest until tomorrow", "Styled bed retains sleep interaction")
	Game.ui.close()
	Input.action_press("move_left")
	for frame in range(60): await get_tree().physics_frame
	Input.action_release("move_left")
	check(Game.player.position.x >= 203, "Styled left wall still blocks movement")
	Game.player.position = Vector2(448, 480)
	await settle()
	check(detector.choose(detector.get_overlapping_areas()) == target("door"), "Threshold still identifies the exit")
	target("door").interact()
	await settle()
	check(Game.scenes.location == "mainland" and not camera.top_level and camera.zoom == Vector2.ONE, "Leaving restores the street camera")
	check(Game.scenes.travel("room", true), "Room can be re-entered")
	await settle()
	check(Game.housing.place_chair(Vector2i(12, 9)), "Existing furniture placement remains supported")
	await settle()
	check(Game.housing.furniture.size() == 1 and main.district.has_node("RoomInterior"), "Rebuilding for placed furniture preserves the interior")
	Game.housing.current = "apartment"
	Game.housing.changed.emit()
	await settle()
	check(main.district.get_node("RoomInterior").right_wall == 27, "Apartment retains its wider footprint")
	check(camera.global_position.x == 528, "Camera recentres on the wider apartment")
	await capture("apartment")
	TimeManager.current_hour = 21
	TimeManager.time_changed.emit()
	await settle()
	await capture("night")
	print("ROOM INTERIOR: PASS" if failures == 0 else "ROOM INTERIOR: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

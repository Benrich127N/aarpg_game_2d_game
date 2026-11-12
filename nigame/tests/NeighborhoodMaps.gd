extends Node
var failures := 0
var checks := 0

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)

func settle() -> void:
	for frame in range(4): await get_tree().physics_frame

func target(kind: String, id: String) -> Area2D:
	for item in get_tree().get_nodes_in_group("interactables"):
		if item.is_inside_tree() and item.kind == kind and item.action_id == id: return item
	return null

func walk_to(at: Vector2) -> void:
	for frame in range(240):
		for action in ["move_left", "move_right", "move_up", "move_down"]: Input.action_release(action)
		var offset: Vector2 = at - Game.player.position
		if offset.length() <= 6: break
		if absf(offset.x) > 4: Input.action_press("move_right" if offset.x > 0 else "move_left")
		if absf(offset.y) > 4: Input.action_press("move_down" if offset.y > 0 else "move_up")
		await get_tree().physics_frame
	for action in ["move_left", "move_right", "move_up", "move_down"]: Input.action_release(action)
	await settle()
	check(Game.player.position.distance_to(at) < 10, "Walkable route to " + str(at))

func near(kind: String, id: String) -> void:
	var item := target(kind, id)
	check(item != null, "Interaction exists: " + kind + "/" + id)
	if item == null: return
	var detector: Area2D = Game.player.get_node("InteractionArea")
	check(detector.get_overlapping_areas().has(item), "Interaction reachable: " + kind + "/" + id)
	item.interact()

func press(label: String) -> void:
	if Game.ui.dialogue_card.visible:
		for choice in Game.ui.dialogue_card.response_buttons:
			if choice.text == label:
				choice.pressed.emit()
				return
	for child in Game.ui.body.get_children():
		if child is Button and child.text == label:
			check(not child.disabled, "Button enabled: " + label)
			child.pressed.emit()
			return
	check(false, "Button found: " + label)

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	Game.player.get_node("Camera2D").reset_smoothing()
	Game.player.get_node("Camera2D").force_update_scroll()
	get_tree().get_first_node_in_group("hud").toast.hide()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.godot/review-neighborhood-" + label + ".png")

func save_round_trip(location: String) -> void:
	var at: Vector2 = Game.player.position
	Game.save.enabled = true
	check(Game.save.write_save(), "Save at " + location)
	Game.save.enabled = false
	Global.cash += 1
	check(Game.save.load_save(), "Load at " + location)
	await settle()
	check(Game.scenes.location == location and Game.player.position.distance_to(at) < 1, "Restore location and position: " + location)

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.save.path = "res://.godot/neighborhood-tests/%s/slot.json" % DisplayServer.get_name()
	Game.reset()
	TimeManager.clock_paused = true
	var main := preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	await settle()
	check(Game.scenes.travel("mainland", true), "Leave home")
	await settle()
	var initial_cash := Global.cash
	var initial_time: int = Game.jobs.now()
	Game.player.position = Vector2(320, 832)
	await settle()
	near("door", "courtyard")
	await settle()
	check(Game.scenes.location == "courtyard", "Courtyard entrance opens separate scene")
	check(Global.cash == initial_cash and Game.jobs.now() == initial_time, "Local doorway is free and immediate")
	check(Game.player.get_node("Camera2D").top_level, "Courtyard camera frames whole map")
	check(Game.player.test_move(Game.player.transform, Vector2(0, 96)), "Courtyard gate boundary prevents walking out of frame")
	check(main.district.get_node("Roads").get_used_cells().is_empty(), "No street tiles across courtyard")
	check(not Game.scenes.travel("provisions", true), "Cannot jump directly between local venues")
	await walk_to(Vector2(640, 352))
	near("place", "garden")
	check(Game.ui.heading.text == "Bisi's garden plan", "Garden plan opens")
	Game.ui.close()
	await walk_to(Vector2(688, 400))
	near("npc", "bisi")
	check(Game.modal_open, "Bisi conversation available in courtyard")
	Game.ui.close()
	await walk_to(Vector2(688, 512))
	await walk_to(Vector2(448, 512))
	near("place", "bench")
	Global.change_energy(-20)
	var before_energy := Global.energy
	var before_time: int = Game.jobs.now()
	press("Sit for 15 minutes · +5 energy")
	check(Global.energy == before_energy + 5 and Game.jobs.now() == before_time + 15, "Bench trades time for rest")
	await capture("courtyard")
	await save_round_trip("courtyard")
	await walk_to(Vector2(640, 536))
	near("door", "mainland")
	await settle()
	check(Game.player.position == Vector2(320, 800), "Courtyard exit returns to its own street gate")
	Game.player.position = Vector2(960, 384)
	await settle()
	near("door", "provisions")
	await settle()
	check(Game.scenes.location == "provisions", "Shop entrance opens separate scene")
	check(Game.player.test_move(Game.player.transform, Vector2(0, 96)), "Shop threshold prevents walking out of frame")
	await walk_to(Vector2(640, 368))
	await walk_to(Vector2(416, 368))
	near("npc", "sade")
	check(Game.modal_open, "Shopkeeper is reachable")
	Game.ui.close()
	await walk_to(Vector2(640, 368))
	await walk_to(Vector2(640, 512))
	await walk_to(Vector2(368, 512))
	near("shop", "kiosk")
	var before_cash := Global.cash
	press("Water sachet · ₦50 · +5 hunger")
	check(Global.cash == before_cash - 50 and Game.inventory.items.get("pure_water", 0) == 1, "Indoor counter purchases work")
	Game.ui.close()
	await walk_to(Vector2(864, 512))
	Game.jobs.completed = 1
	Game.jobs.attempts = 1
	near("job", "stock")
	press("Start job")
	check(Game.jobs.active.get("id", "") == "stock", "Stockroom starts existing paid job")
	check(not Game.scenes.travel("mainland", true), "Cannot leave during active stock shift")
	Game.ui.close()
	await save_round_trip("provisions")
	before_cash = Global.cash
	for item in Game.jobs.stock_order.duplicate(): Game.jobs.match_stock(item)
	check(Global.cash == before_cash + 1200, "Stockroom pays existing stock reward once")
	await capture("shop")
	await walk_to(Vector2(640, 536))
	near("door", "mainland")
	await settle()
	check(Game.player.position == Vector2(960, 416), "Shop exit returns outside provisions frontage")
	Game.player.position = Vector2(736, 912)
	await settle()
	near("place", "cafe")
	check(Game.ui.heading.text == "Amara's outdoor tables", "Street cafe seating opens")
	press("Eat from your bag")
	check(Game.ui.heading.text == "Your bag", "Cafe opens existing food inventory")
	Game.ui.close()
	await capture("mainland")
	check(Game.scenes.travel("club", true), "Club remains reachable")
	await settle()
	await walk_to(Vector2(656, 368))
	near("venue_person", "nneka")
	check(Game.ui.dialogue_card.visible and Game.ui.dialogue_card.speaker.text == "Nneka", "Club supervisor uses portrait conversation")
	press("Ask about bar work")
	check(Game.ui.heading.text == "Club bar shift", "Supervisor offers paid bar work")
	Game.ui.close()
	await walk_to(Vector2(704, 448))
	near("place", "dance")
	before_time = Game.jobs.now()
	before_energy = Global.energy
	press("Dance for 10 minutes")
	check(Global.energy == before_energy - 5 and Game.jobs.now() == before_time + 10, "Dance activity charges time and energy")
	await capture("club")
	check(target("venue_person", "kemi") != null and target("venue_person", "dele") != null, "Club has guest and DJ")
	check(get_tree().get_nodes_in_group("player").size() == 1, "Single player preserved through all map changes")
	print("NEIGHBORHOOD MAPS: %s · %d checks" % ["PASS" if failures == 0 else "FAIL", checks])
	get_tree().quit(0 if failures == 0 else 1)

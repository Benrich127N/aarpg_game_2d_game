extends Node
var failures := 0

func check(value: bool, description: String) -> void:
	if not value:
		failures += 1
		push_error(description)

func settle() -> void:
	for frame in range(4): await get_tree().physics_frame

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.godot/review-" + label + ".png")

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.reset()
	TimeManager.clock_paused = true
	var main := preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	await settle()
	Game.player.position = Vector2(448, 520)
	Input.action_press("move_down")
	for frame in range(90): await get_tree().physics_frame
	Input.action_release("move_down")
	check(Game.player.position.y < 551, "Room threshold prevents walking outside the fixed camera")
	Game.scenes.pending_position = Vector2(1200, 900)
	main.rebuild_world()
	await settle()
	check(Game.player.position == Vector2(448, 448), "Old out-of-frame room saves recover at the room spawn")
	check(Game.scenes.travel("mainland", true), "Leave home")
	await settle()
	var camera: Camera2D = Game.player.get_node("Camera2D")
	for corner in [Vector2(48, 48), Vector2(1872, 48), Vector2(48, 1030), Vector2(1872, 1030)]:
		Game.player.position = corner
		camera.reset_smoothing()
		await settle()
		camera.force_update_scroll()
		var screen: Vector2 = Game.player.get_global_transform_with_canvas().origin
		var viewport := get_viewport().get_visible_rect().size
		check(screen.x >= 24 and screen.x <= viewport.x - 24 and screen.y >= 120 and screen.y <= viewport.y - 132, "Street corner keeps the full character clear of the HUD: " + str(corner))
	check(not Game.jobs.start("club"), "Club work requires visiting the interior")
	check(not Game.scenes.travel("club"), "Club uses its street doorway")
	check(Game.scenes.travel("club", true), "Enter separate club scene")
	await settle()
	check(main.district.has_node("ClubInterior") and camera.top_level, "Club has its own interior and fixed camera")
	check(main.district.get_node("Roads").get_used_cells().is_empty(), "Street road tiles do not cover the club floor")
	check(Game.player.position == Vector2(640, 536), "Club spawn is inside the exit")
	await capture("club")
	check(Game.jobs.start("club"), "Club shift available without career requirements")
	var token: int = Game.jobs.active.token
	var cash_before := Global.cash
	check(not Game.jobs.finish(token, true), "Cannot collect pay before serving guests")
	check(not Game.scenes.travel("mainland", true), "Active shift prevents leaving")
	var saved: Dictionary = Game.save.snapshot()
	check(Game.save.valid(saved), "Active club shift validates for saving")
	Game.save.apply(saved)
	await settle()
	Game.ui.job("club")
	check(Game.ui.heading.text == "Club bar shift", "Shift UI resumes after loading")
	Game.ui.close()
	for drink in Game.jobs.stock_order.duplicate(): Game.jobs.serve_club(drink)
	check(Global.cash == cash_before + 1500 and Game.jobs.completed == 1, "Three correct drinks pay exactly once")
	check(not Game.jobs.finish(token, true), "Completed shift cannot pay twice")
	check(not Game.jobs.start("club"), "Club cooldown blocks immediate repeat")
	check(Game.save.valid(Game.save.snapshot()), "Completed club shift can be saved")
	check(Game.scenes.travel("mainland", true), "Exit club")
	await settle()
	check(Game.player.position == Vector2(1280, 800) and not camera.top_level, "Exit returns to club street doorway and restores follow camera")
	check(Game.scenes.travel("club", true), "Re-enter club")
	await settle()
	TimeManager.advance_minutes(180)
	check(Game.jobs.start("club"), "Cooldown expires")
	var wrong: String = "water" if Game.jobs.stock_order[0] != "water" else "juice"
	cash_before = Global.cash
	check(not Game.jobs.serve_club(wrong) and Game.jobs.active.is_empty() and Global.cash == cash_before, "Wrong drink ends shift without pay")
	print("CLUB AND FRAMING: PASS" if failures == 0 else "CLUB AND FRAMING: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

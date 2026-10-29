extends Node

var failures: int = 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _ready() -> void:
	for binding in [["move_left", KEY_A, KEY_LEFT], ["move_right", KEY_D, KEY_RIGHT], ["move_up", KEY_W, KEY_UP], ["move_down", KEY_S, KEY_DOWN], ["interact", KEY_E], ["pause", KEY_ESCAPE]]:
		for key_index in range(1, binding.size()):
			var event := InputEventKey.new()
			event.physical_keycode = binding[key_index]
			check(InputMap.event_is_action(event, binding[0]), "Keyboard binding: " + binding[0])
	TimeManager.clock_paused = true
	check(not Global.add_cash(-10), "Negative credit rejected")
	check(not Global.add_cash(0), "Zero credit rejected")
	check(not Global.spend_cash(-10), "Negative debit rejected")
	check(not Global.spend_cash(5001), "Unaffordable debit rejected")
	check(Global.cash == 5000, "Rejected transactions leave cash unchanged")
	check(Global.add_cash(200) and Global.spend_cash(100), "Valid cash transactions")
	check(Global.cash == 5100, "Correct integer balance")
	Global.cash = 9223372036854775807
	check(not Global.add_cash(1), "Overflow credit rejected")
	Global.cash = 5000
	Global.change_health(-500)
	Global.change_energy(500)
	Global.change_hunger(-500)
	Global.change_reputation(500)
	check(Global.health == 0 and Global.energy == 100 and Global.hunger == 0 and Global.reputation == 100, "All needs clamped")
	Global.health = 100
	Global.hunger = 100
	TimeManager.current_hour = 23
	TimeManager.current_minute = 59
	var time_events: Array[int] = [0]
	TimeManager.time_changed.connect(func() -> void: time_events[0] += 1)
	TimeManager.advance_minutes(1)
	check(TimeManager.current_day == 2 and TimeManager.current_hour == 0 and TimeManager.current_minute == 0, "Midnight rollover")
	check(Global.hunger == 90 and time_events[0] == 1, "Midnight hunger and time signal")
	TimeManager.advance_minutes(2880)
	check(TimeManager.current_day == 4 and Global.hunger == 0, "Multi-day advancement and hunger clamp")
	TimeManager.advance_minutes(-1)
	check(TimeManager.current_day == 4, "Negative time rejected")
	check(TimeManager.get_time_string() == "12:00 AM", "Midnight display")
	var world: Node2D = preload("res://Scenes/test_world.tscn").instantiate()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	await get_tree().physics_frame
	var player: CharacterBody2D = world.get_node("Player")
	var hud: CanvasLayer = world.get_node("HUD")
	check(hud.cash_label.text == "₦5,000", "Initial HUD cash")
	Global.add_cash(25)
	check(hud.cash_label.text == "₦5,025", "HUD signal update")
	player.position = Vector2(400, 700)
	Input.action_press("move_right")
	for frame in range(30):
		await get_tree().physics_frame
	var straight_speed: float = player.velocity.length()
	Input.action_press("move_down")
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(is_equal_approx(player.velocity.length(), straight_speed), "Diagonal speed equals straight speed")
	Input.action_release("move_down")
	player.position = Vector2(1040, 480)
	for frame in range(60):
		await get_tree().physics_frame
	check(player.position.x < 1080 and player.get_slide_collision_count() > 0, "Wall blocks player")
	Input.action_release("move_right")
	TimeManager.clock_paused = false
	TimeManager.elapsed_seconds = 0.0
	TimeManager.seconds_per_minute = 0.01
	var old_minute: int = TimeManager.current_minute
	var old_position: Vector2 = player.position
	hud.set_paused(true)
	Input.action_press("move_left")
	for frame in range(10):
		await get_tree().process_frame
	check(player.position == old_position and TimeManager.current_minute == old_minute, "Pause freezes player and clock")
	hud.set_paused(false)
	Input.action_release("move_left")
	TimeManager.clock_paused = true
	for size in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1600, 900)]:
		get_window().size = size
		await get_tree().process_frame
		await get_tree().process_frame
		check(hud.get_node("MainUI").size.x > 0 and hud.time_label.get_global_rect().end.x <= hud.get_node("MainUI").size.x, "HUD fits window width")
	print("STEPS 3–5: ", "PASS" if failures == 0 else "FAIL (%d)" % failures)
	get_tree().quit(0 if failures == 0 else 1)



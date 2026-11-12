extends Node
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func settle() -> void:
	for frame in range(4): await get_tree().process_frame

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.godot/review-pause-" + name + ".png")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.auto_load = false
	Game.save.enabled = true
	Game.save.path = "res://.godot/pause-test-%d/slot.json" % Time.get_ticks_usec()
	Game.settings.path = "res://.godot/pause-test-settings.cfg"
	Game.settings.set_value("text_scale", 1.0)
	Game.reset()
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(main)
	await settle()
	var hud: Node = get_tree().get_first_node_in_group("hud")
	var menu: Control = hud.pause_menu
	hud.set_paused(true)
	await settle()
	check(hud.pause_overlay.visible and menu.art.visible, "Pause opens illustrated menu")
	check(menu.buttons.size() == 7, "Pause retains all seven actions")
	check(menu.art.headline.text == "The street\ncan wait.", "Pause uses its own room vignette")
	check(menu.context.text.contains("Day 1") and menu.context.text.contains("5,000"), "Pause shows current session details")
	check(get_viewport().gui_get_focus_owner() == hud.resume_button, "Resume receives keyboard focus")
	var position_before: Vector2 = Game.player.position
	var minute_before: int = TimeManager.current_minute
	Input.action_press("move_right")
	await settle()
	Input.action_release("move_right")
	check(Game.player.position == position_before and TimeManager.current_minute == minute_before, "Pause keeps gameplay and clock frozen")
	await capture("menu")
	menu.buttons.Settings.pressed.emit()
	await settle()
	check(Game.ui.overlay.visible and Game.ui.heading.text == "Settings", "Pause opens Settings")
	Game.ui.close()
	await settle()
	check(get_tree().paused and hud.pause_overlay.visible and get_viewport().gui_get_focus_owner() == hud.resume_button, "Closing Settings returns focus to pause")
	menu.buttons.Credits.pressed.emit()
	await settle()
	check(Game.ui.heading.text == "Credits", "Pause opens Credits")
	Game.ui.close()
	await settle()
	menu.buttons["Save game"].pressed.emit()
	check(FileAccess.file_exists(Game.save.path) and hud.pause_notice.text == "Game saved.", "Save action reports success in pause card")
	Game.settings.set_value("text_scale", 1.4)
	get_window().size = Vector2i(960, 540)
	await settle()
	check(menu.panel.get_global_rect().end.x <= menu.size.x, "Pause panel fits at maximum text size")
	menu.buttons["Save & return to title"].grab_focus()
	await settle()
	var bottom: Rect2 = menu.buttons["Save & return to title"].get_global_rect()
	check(bottom.end.y <= menu.scroll.get_global_rect().end.y + 1, "Keyboard focus scrolls lower options into view")
	await capture("large-text")
	hud.resume_button.pressed.emit()
	check(not get_tree().paused and not hud.pause_overlay.visible and hud.control_dock.visible, "Resume returns to gameplay")
	Game.settings.set_value("text_scale", 1.0)
	print("PAUSE MENU: PASS" if failures == 0 else "PAUSE MENU: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

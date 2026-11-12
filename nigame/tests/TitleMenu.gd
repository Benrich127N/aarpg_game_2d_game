extends Node
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func settle() -> void:
	for frame in range(3): await get_tree().process_frame

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.godot/review-menu-" + name + ".png")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.auto_load = false
	Game.save.enabled = false
	Game.save.path = "res://.godot/menu-test-%d/slot.json" % Time.get_ticks_usec()
	Game.settings.path = "res://.godot/menu-test-settings.cfg"
	Game.reset()
	Game.settings.set_value("text_scale", 1.0)
	var menu: Node = preload("res://Scenes/ui/MainMenu.tscn").instantiate()
	add_child(menu)
	await settle()
	var ui: Node = Game.ui
	check(ui.title_page.visible and not ui.overlay.visible, "Dedicated menu appears without modal backdrop")
	check(ui.title_page.buttons.Continue.disabled, "Continue disabled without a valid save")
	check(get_viewport().gui_get_focus_owner() == ui.title_page.buttons["New game"], "New game receives keyboard focus without a save")
	var down := InputEventAction.new()
	down.action = "ui_down"
	down.pressed = true
	Input.parse_input_event(down)
	await settle()
	check(get_viewport().gui_get_focus_owner() == ui.title_page.buttons.Settings, "Keyboard moves to the next enabled action")
	ui.title_page.buttons["New game"].pressed.emit()
	await settle()
	check(ui.overlay.visible and not ui.title_page.visible and ui.heading.text == "Start fresh?", "New game retains its confirmation")
	check(ui.page_art.visible and ui.page_backdrop.visible, "New game has an illustrated pixel page")
	await capture("new-game")
	ui.close()
	await settle()
	ui.title_page.buttons.Settings.pressed.emit()
	await settle()
	check(ui.heading.text == "Settings" and ui.overlay.visible, "Settings opens from styled menu")
	check(ui.page_art.visible and ui.page_art.headline.text == "Make it\nyour own.", "Settings uses its own pixel illustration")
	var slider: HSlider = ui.body.find_child("MusicVolume", true, false)
	check(slider != null and ui.overlay.theme.has_icon("grabber", "HSlider"), "Settings has custom pixel slider controls")
	var old_volume: float = Game.settings.values.Music
	slider.value = 0.25
	check(is_equal_approx(Game.settings.values.Music, 0.25), "Styled volume control still changes settings")
	slider.value = old_volume
	await settle()
	await capture("settings")
	Game.settings.set_value("text_scale", 1.4)
	ui.settings_menu()
	await settle()
	check(ui.page_scroll.get_v_scroll_bar().max_value > 0, "Settings content scrolls at large text size")
	check(ui.page_panel.get_global_rect().end.x <= ui.overlay.size.x, "Illustrated page fits at large text size")
	await capture("settings-large-text")
	Game.settings.set_value("text_scale", 1.0)
	ui.close()
	await settle()
	ui.title_page.buttons.Credits.pressed.emit()
	await settle()
	check(ui.heading.text == "Credits" and ui.overlay.visible, "Credits opens from styled menu")
	check(ui.page_art.headline.text == "The people.\nThe place.", "Credits uses its own pixel illustration")
	await capture("credits")
	ui.close()
	await settle()
	Game.save.enabled = true
	check(Game.save.write_save(), "Isolated valid menu test save created")
	ui.title_screen()
	await settle()
	check(not ui.title_page.buttons.Continue.disabled, "Continue enabled with a valid save")
	check(get_viewport().gui_get_focus_owner() == ui.title_page.buttons.Continue, "Continue receives keyboard focus with a save")
	Game.settings.set_value("text_scale", 1.4)
	get_window().size = Vector2i(960, 540)
	await settle()
	for button in ui.title_page.buttons.values():
		check(button.size.x >= button.get_minimum_size().x, "Buttons fit largest text setting")
	check(ui.title_page.title.size.x >= ui.title_page.title.get_minimum_size().x, "Title fits largest text setting")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/review-title-large-text.png")
	print("TITLE MENU: PASS" if failures == 0 else "TITLE MENU: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

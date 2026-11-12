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
	get_viewport().get_texture().get_image().save_png("res://.godot/review-settings-" + name + ".png")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/settings-tabs-test.cfg"
	Game.settings.set_value("text_scale", 1.0)
	Game.settings.set_value("reduced_motion", false)
	Game.settings.set_value("fullscreen", false)
	Game.reset()
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	await settle()
	var ui: Node = Game.ui
	var hud: Node = get_tree().get_first_node_in_group("hud")
	hud.set_paused(true)
	ui.settings_menu()
	await settle()
	check(ui.page_art.visible and ui.page_backdrop.visible and not ui.title_mode, "Pause-menu settings has illustrated styling")
	check(ui.body.find_child("SettingsTabs", true, false).get_child_count() == 3, "Settings provides three distinct tabs")
	var slider: HSlider = ui.body.find_child("MusicVolume", true, false)
	slider.value = 0.35
	check(is_equal_approx(Game.settings.values.Music, 0.35), "Audio slider changes volume")
	check(ui.body.find_child("MusicValue", true, false).text == "35%", "Audio percentage updates live")
	await capture("audio")
	ui.body.find_child("DisplayTab", true, false).pressed.emit()
	await settle()
	check(ui.settings_view.selected_tab == "display", "Display tab opens")
	ui.body.find_child("reduced_motion_On", true, false).pressed.emit()
	await settle()
	check(Game.settings.values.reduced_motion and not Game.player.get_node("Camera2D").position_smoothing_enabled, "Reduced-motion choice applies")
	check(get_viewport().gui_get_focus_owner().name == "reduced_motion_On", "Focus stays on selected setting after rebuilding")
	ui.body.find_child("text_scale_140", true, false).pressed.emit()
	await settle()
	check(is_equal_approx(Game.settings.values.text_scale, 1.4), "Text-size choice applies")
	var config := ConfigFile.new()
	check(config.load(Game.settings.path) == OK and is_equal_approx(config.get_value("settings", "text_scale"), 1.4), "Settings save to disk")
	if DisplayServer.get_name() == "headless":
		ui.body.find_child("fullscreen_On", true, false).pressed.emit()
		await settle()
		check(Game.settings.values.fullscreen, "Fullscreen choice applies")
		ui.body.find_child("fullscreen_Off", true, false).pressed.emit()
		await settle()
	await capture("display")
	ui.body.find_child("ControlsTab", true, false).pressed.emit()
	await settle()
	check(ui.body.find_child("KeyboardBindings", true, false).get_child_count() == 10, "Controls tab displays keyboard keycaps")
	await capture("controls")
	ui.body.find_child("AudioTab", true, false).pressed.emit()
	await settle()
	for bus in ["Music", "Ambience", "SFX"]:
		check(ui.body.find_child(bus + "Value", true, false).get_line_count() == 1, "Volume percentage stays on one line at maximum text size")
	ui.body.find_child("PreviewFootsteps", true, false).pressed.emit()
	check(ui.settings_view.selected_tab == "audio" and ui.overlay.visible, "Sound preview stays on Audio tab")
	get_window().size = Vector2i(960, 540)
	await settle()
	check(ui.page_panel.get_global_rect().end.x <= ui.overlay.size.x, "Settings fits the smaller window")
	await capture("large-text")
	ui.close()
	check(not Game.modal_open and hud.pause_overlay.visible, "Closing settings returns to pause menu")
	hud.set_paused(false)
	Game.settings.set_value("text_scale", 1.0)
	print("SETTINGS TABS: PASS" if failures == 0 else "SETTINGS TABS: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

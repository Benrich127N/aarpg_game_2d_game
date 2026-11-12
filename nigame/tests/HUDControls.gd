extends Node
const PIXEL = preload("res://scripts/ui/PixelMenuTheme.gd")
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func settle() -> void:
	for tick in range(3): await get_tree().physics_frame

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/hud-controls-settings.cfg"
	Game.reset()
	Game.settings.set_value("text_scale", 1.0)
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	Game.scenes.travel("mainland", true)
	await settle()
	var hud: Node = get_tree().get_first_node_in_group("hud")
	var ui: Node = Game.ui
	Game.player.position = Vector2(1248, 520)
	await settle()
	check(hud.control_buttons.size() == 4 and hud.control_dock.visible, "Four pixel controls appear during play")
	check(hud.control_buttons.interact.disabled, "Interact is unavailable without a nearby target")
	check(not hud.prompt_frame.visible, "Empty interaction hint does not draw a box")
	hud.control_buttons.bag.pressed.emit()
	check(ui.heading.text == "Your bag" and Game.modal_open, "Bag control opens inventory")
	ui.close()
	hud.control_buttons.phone.pressed.emit()
	check(ui.heading.text == "Phone" and Game.modal_open, "Phone control opens phone")
	ui.close()
	hud.control_buttons.menu.pressed.emit()
	check(get_tree().paused and hud.pause_overlay.visible and not hud.control_dock.visible, "Menu control pauses and hides gameplay controls")
	hud.resume_button.pressed.emit()
	check(not get_tree().paused and hud.control_dock.visible, "Resume restores controls")
	Game.player.position = Game.events.target("tunde") + Vector2(0, 30)
	await settle()
	check(not hud.control_buttons.interact.disabled and hud.prompt.text == "Talk to Tunde", "Nearby NPC enables contextual interaction")
	check(hud.prompt_frame.visible, "Nearby target has a framed caption")
	hud.control_buttons.interact.pressed.emit()
	await settle()
	check(ui.dialogue_card.visible and not hud.control_dock.visible, "Clicking Interact talks to the target and hides the dock")
	var options: Array = ui.dialogue_card.response_buttons
	options[1].grab_focus()
	await settle()
	check(options[1].icon == PIXEL.selector(true) and options[0].icon == PIXEL.selector(false), "Selection arrow follows keyboard focus")
	check(options[1].get_theme_stylebox("focus").bg_color.a > 0, "Focused dialogue option has a visible highlight")
	ui.close()
	Game.settings.set_value("text_scale", 1.4)
	get_window().size = Vector2i(960, 540)
	await settle()
	for button in hud.control_buttons.values():
		var rect: Rect2 = button.get_global_rect()
		check(rect.position.x >= 0 and rect.end.x <= hud.get_node("MainUI").size.x, "Pixel controls fit at largest text size")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/review-controls-large-text.png")
	print("HUD CONTROLS: PASS" if failures == 0 else "HUD CONTROLS: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

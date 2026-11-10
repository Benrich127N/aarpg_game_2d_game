extends Node
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func settle() -> void:
	for frame in range(3): await get_tree().process_frame

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await settle()
	event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/dialogue-card-settings.cfg"
	Game.reset()
	Game.settings.set_value("text_scale", 1.0)
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	Game.scenes.travel("mainland", true)
	await settle()
	var ui: Node = Game.ui
	var hud: Node = get_tree().get_first_node_in_group("hud")
	var card: Control = ui.dialogue_card
	for id in Game.relationships.NPC_IDS:
		ui.dialogue(id)
		await settle()
		check(card.visible and not ui.overlay.visible, "NPC uses undimmed bottom card: " + id)
		check(card.speaker.text == Game.dialogue.data[id].name and card.portrait.texture != null, "NPC name and portrait: " + id)
		check(card.response_buttons.size() <= 3, "At most three responses: " + id)
		check(not hud.prompt.visible and not hud.toast.visible, "Dialogue suppresses overlapping prompts")
	ui.dialogue("tunde")
	await settle()
	var position_before: Vector2 = Game.player.position
	Input.action_press("move_right")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("move_right")
	check(Game.player.position == position_before, "Conversation holds player position")
	card.response_buttons[1].pressed.emit()
	await settle()
	check(Game.dialogue.flags.has("tunde:help") and card.visible and not ui.overlay.visible, "Advice keeps quest action and stays in the card")
	await key(KEY_ENTER)
	check(card.choices.size() == 3, "Enter selects focused Back to conversation once")
	var original: String = Game.dialogue.data.tunde.greeting
	Game.dialogue.data.tunde.greeting = "A neighbour has a parcel waiting. ".repeat(16).strip_edges()
	ui.dialogue("tunde")
	await settle()
	check(card.pages.size() > 1 and card.response_buttons.size() == 1, "Long dialogue is paged before responses appear")
	var initial_page: int = card.page
	await key(KEY_E)
	check(card.page == initial_page + 1, "E advances exactly one passage")
	for remaining_page in range(card.pages.size() - 1 - card.page):
		await key(KEY_ENTER)
	check(card.response_buttons.size() == 3 and not Game.dialogue.flags.has("tunde:greet"), "Reaching final page does not auto-select a response")
	await key(KEY_E)
	check(Game.dialogue.flags.has("tunde:greet") and Game.relationships.values.tunde.friendship == 5, "Confirm executes greeting once")
	Game.dialogue.data.tunde.greeting = original
	await key(KEY_ESCAPE)
	check(not card.visible and not Game.modal_open and not Global.input_blocked, "Escape closes and restores player input")
	check(hud.prompt.visible and not get_tree().paused, "Escape restores prompt without opening pause menu")
	check(Game.jobs.start("delivery"), "Delivery available for Bisi choice coverage")
	ui.dialogue("bisi")
	await settle()
	check(card.choices.size() == 4 and card.response_buttons.size() == 3, "Extra choices are paged with More options")
	card.response_buttons[2].pressed.emit()
	await settle()
	check(card.response_buttons[0].text == "Hand over parcel", "More options reaches parcel handover")
	card.response_buttons[0].pressed.emit()
	await settle()
	check(card.visible and not ui.overlay.visible and card.full_text.contains("Collect the parcel"), "Failed handover stays in bottom card")
	Game.settings.set_value("text_scale", 1.4)
	get_window().size = Vector2i(960, 540)
	await settle()
	check(card.panel.get_global_rect().position.y > hud.meters.Health.get_global_rect().end.y, "Large text leaves HUD visible")
	check(card.panel.get_global_rect().end.y <= card.size.y, "Card stays above screen bottom")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/review-dialogue-large-text.png")
	Game.settings.set_value("text_scale", 1.0)
	ui.dialogue("amara")
	await settle()
	card.response_buttons[2].pressed.emit()
	await settle()
	check(ui.overlay.visible and not card.visible and ui.heading.text == "Food stall", "Shop response opens shop and clears dialogue card")
	ui.close()
	check(not Game.modal_open and hud.prompt.visible, "Closing shop restores interaction prompt")
	print("DIALOGUE CARD: PASS" if failures == 0 else "DIALOGUE CARD: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

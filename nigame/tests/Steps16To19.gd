extends Node
var failures: int = 0
var checks: int = 0
func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/qa-settings.cfg"
	Game.reset()
	Game.events.state.next_check = 2000000000
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(main)
	await get_tree().physics_frame
	check(not Game.events.trigger("rain"), "No outdoor event inside home")
	var wallet: int = Global.cash
	check(not Game.wardrobe.buy("missing") and not Game.wardrobe.equip("gold"), "Unknown or unowned clothes rejected")
	check(Game.wardrobe.buy("indigo") and Global.cash == wallet - 800, "Clothing purchase debits correct price")
	wallet = Global.cash
	check(not Game.wardrobe.buy("indigo") and Global.cash == wallet, "Duplicate shirt purchase rejected")
	check(Game.wardrobe.equip("indigo"), "Owned shirt equipped")
	check(not Game.wardrobe.customize("skin", 9), "Invalid customization rejected")
	var player: CharacterBody2D = main.get_node("Player")
	for animation in ["idle_up", "idle_down", "idle_side", "walk_up", "walk_down", "walk_side"]:
		for layer in player.layers:
			check(layer.sprite_frames.get_frame_texture(animation, 0).get_size() == Vector2(32,48), "Layer frame alignment and dimensions")
	Input.action_press("move_left")
	for frame in range(4): await get_tree().physics_frame
	for layer in player.layers: check(layer.flip_h and layer.position == player.sprite.position, "Left-facing layers remain aligned")
	Input.action_release("move_left")
	var wealth: int = Game.progression.net_worth()
	check(Game.wardrobe.transfer(1000, true) and Game.progression.net_worth() == wealth, "Bank deposit preserves net worth")
	check(Game.wardrobe.transfer(500, false) and Game.wardrobe.state.bank == 500, "Bank withdrawal")
	wallet = Global.cash
	check(not Game.wardrobe.transfer(-5, true) and not Game.wardrobe.transfer(999999, false) and Global.cash == wallet, "Invalid bank transfer leaves money unchanged")
	Game.ui.perform("phone", "")
	check(Game.modal_open and Game.ui.heading.text == "Phone", "Phone hub opens")
	for tab in ["bank", "contacts", "jobs", "map", "quests"]:
		Game.ui.phone_view.show_tab(tab)
		check(Game.wardrobe.state.phone_tab == tab, "Phone remembers tab")
	Game.ui.close()
	check(Game.settings.set_value("SFX", 0) and AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "SFX slider mutes its bus")
	check(Game.settings.set_value("text_scale", 1.2) and Game.ui.overlay.theme.default_font_size >= 21, "Readable text scale applied")
	check(Game.settings.set_value("reduced_motion", true) and not player.get_node("Camera2D").position_smoothing_enabled, "Reduced motion disables camera smoothing")
	Game.settings.set_value("text_scale", 1.0)
	Game.settings.set_value("reduced_motion", false)
	Game.settings.set_value("SFX", 0.65)
	var config := ConfigFile.new()
	check(config.load(Game.settings.path) == OK and config.get_value("settings", "SFX") == 0.65, "Settings persist to disk")
	for bus in ["Music", "Ambience", "SFX"]: check(AudioServer.get_bus_index(bus) >= 0, "Audio bus exists")
	check(Game.audio.streams.music.loop_mode == AudioStreamWAV.LOOP_FORWARD and Game.audio.streams.music.data.size() > 1000, "Original music loop is available")
	Game.scenes.travel("mainland", true)
	for frame in range(5): await get_tree().physics_frame
	check(main.district.has_node("NavigationRegion2D"), "Mainland has navigation region")
	check(Game.events.trigger("rain"), "Eligible rain event triggers")
	check(Game.events.state.weather == "rain" and Game.audio.environment == "rain", "Rain changes ambience")
	check(Game.events.resolve(true) and not Game.events.trigger("rain"), "Event choice consumes event and enforces cooldown")
	check(Game.events.trigger("neighbour"), "Neighbour encounter eligible")
	Global.energy = 0
	check(not Game.events.resolve(true) and Game.events.state.pending == "neighbour", "Event requirements validated before consumption")
	Global.energy = 100
	var reputation: int = Global.reputation
	check(Game.events.resolve(true) and Global.energy == 95 and Global.reputation == reputation + 2, "Encounter applies costs and reward")
	check(not Game.events.resolve(true), "Event reward cannot repeat")
	TimeManager.current_hour = 12
	TimeManager.current_minute = 0
	TimeManager.time_changed.emit()
	var tunde: Area2D
	for node in get_tree().get_nodes_in_group("interactables"):
		if node.kind == "npc" and node.action_id == "tunde": tunde = node
	var distance: float = tunde.position.distance_to(Game.events.target("tunde"))
	player.position = tunde.position + Vector2(0, 80)
	for frame in range(30): await get_tree().physics_frame
	check(tunde.position.distance_to(Game.events.target("tunde")) < distance, "NavigationAgent follows lunch schedule")
	Game.events.state.pending = ""
	Global.cash = 40000
	Global.reputation = 10
	Game.jobs.completed = 3
	Game.jobs.attempts = 3
	check(Game.events.trigger("traffic"), "Traffic event eligible")
	var before: int = Game.jobs.now()
	check(Game.scenes.travel("business") and Game.jobs.now() - before == 80, "Traffic adds travel delay once")
	check(Game.events.state.positions.has("tunde"), "Offscreen NPC state simulated without actors")
	TimeManager.current_hour = 19
	TimeManager.time_changed.emit()
	var effects: Node2D = main.district.get_node("StreetEffects")
	check(effects.lights[0].visible, "Streetlights switch on at night")
	Game.events.state.weather = "rain"
	Game.settings.set_value("reduced_motion", true)
	check(not effects.is_processing(), "Reduced motion stops rain animation")
	Game.settings.set_value("reduced_motion", false)
	Game.ui.wardrobe()
	Game.ui.settings_menu()
	Game.ui.credits()
	Game.ui.close()
	var data: Dictionary = Game.save.snapshot()
	check(Game.save.valid(data), "Version 3 full snapshot validates")
	var bad: Dictionary = data.duplicate(true)
	bad.character.bank = -1
	check(not Game.save.valid(bad), "Invalid bank save rejected")
	bad = data.duplicate(true)
	bad.character.shirt = "unowned"
	check(not Game.save.valid(bad), "Invalid outfit save rejected")
	bad = data.duplicate(true)
	bad.world.pending = "fake_event"
	check(not Game.save.valid(bad), "Unknown saved event rejected")
	var old: Dictionary = data.duplicate(true)
	old.version = 2
	old.erase("character")
	old.erase("world")
	var migrated: Dictionary = Game.save.migrate(old)
	check(Game.save.valid(migrated) and migrated.character.shirt == "green" and migrated.character.bank == 0, "Version 2 saves migrate with clean defaults")
	Game.save.path = "res://.godot/steps16-save.json"
	Game.save.enabled = true
	check(Game.save.write_save(), "New state saves")
	Game.reset()
	Game.events.state.next_check = 2000000000
	check(Game.save.load_save() and Game.wardrobe.state.shirt == "indigo" and Game.wardrobe.state.bank == 500 and Game.wardrobe.state.phone_tab == "quests", "Outfit bank and phone state restored")
	check(Game.events.state.cooldowns.has("neighbour"), "Event cooldowns persisted")
	var controller_event := InputEventJoypadButton.new()
	controller_event.button_index = JOY_BUTTON_A
	check(InputMap.event_is_action(controller_event, "interact"), "Controller interact binding")
	Game.ui.close()
	for frame in range(3): await get_tree().process_frame
	print("STEPS 16–19: %s · %d checks" % ["PASS" if failures == 0 else "FAIL (%d)" % failures, checks])
	get_tree().quit(0 if failures == 0 else 1)

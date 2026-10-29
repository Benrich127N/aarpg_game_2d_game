extends Node
const VERSION: int = 3
var path: String = "user://saves/slot_1.json"
var enabled: bool = true
var last_error: String = ""

func snapshot() -> Dictionary:
	var position: Vector2 = Game.player.position if is_instance_valid(Game.player) else Vector2(320, 384)
	return {"version": VERSION,
		"stats": {"cash": Global.cash, "energy": Global.energy, "hunger": Global.hunger, "health": Global.health, "reputation": Global.reputation},
		"clock": {"day": TimeManager.current_day, "hour": TimeManager.current_hour, "minute": TimeManager.current_minute},
		"location": Game.scenes.location, "position": [position.x, position.y],
		"inventory": Game.inventory.items.duplicate(true),
		"jobs": {"active": Game.jobs.active.duplicate(true), "cooldowns": Game.jobs.cooldowns.duplicate(true), "completed": Game.jobs.completed, "attempts": Game.jobs.attempts, "order": Game.jobs.stock_order.duplicate(), "index": Game.jobs.stock_index, "pickup": Game.jobs.delivery_checkpoint},
		"dialogue": Game.dialogue.flags.duplicate(true),
		"relationships": Game.relationships.values.duplicate(true), "greeted": Game.relationships.greeted_day.duplicate(true),
		"quests": Game.quests.objectives.duplicate(true), "claimed": Game.quests.claimed.duplicate(true),
		"housing": {"current": Game.housing.current, "owned": Game.housing.owned.duplicate(true), "next_rent": Game.housing.next_rent_day, "arrears": Game.housing.arrears, "furniture": Game.housing.furniture.duplicate(true), "stored": Game.housing.stored},
		"achievements": Game.progression.achievements.duplicate(true), "world": Game.events.state.duplicate(true), "character": Game.wardrobe.state.duplicate(true)}

func number(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= minimum and value <= maximum

func bool_map(value: Variant, keys: Array) -> bool:
	if not value is Dictionary: return false
	for key in value:
		if not key in keys or not value[key] is bool: return false
	return true

func valid(data: Variant) -> bool:
	if not data is Dictionary or not number(data.get("version"), 1, VERSION): return false
	for key in ["stats", "clock", "inventory", "jobs", "dialogue", "relationships", "greeted", "quests", "claimed", "housing", "achievements", "world", "character"]:
		if not data.get(key) is Dictionary: return false
	for key in ["cash", "energy", "hunger", "health", "reputation"]:
		if not number(data.stats.get(key), 0, 1000000000 if key == "cash" else 100): return false
	if not number(data.clock.get("day"), 1, 1000000) or not number(data.clock.get("hour"), 0, 23) or not number(data.clock.get("minute"), 0, 59): return false
	if not Game.scenes.DESTINATIONS.has(data.get("location")): return false
	if not data.get("position") is Array or data.position.size() != 2: return false
	for coordinate in data.position:
		if not (coordinate is int or coordinate is float) or not is_finite(float(coordinate)) or coordinate < 24 or coordinate > 1900: return false
	if data.position[1] > 1050: return false
	if data.inventory.size() > Game.inventory.CAPACITY: return false
	for id in data.inventory:
		if not Game.inventory.catalog.has(id) or not number(data.inventory[id], 1, Game.inventory.catalog[id].stack_limit): return false
	var jobs: Dictionary = data.jobs
	if not jobs.get("active") is Dictionary or not jobs.get("cooldowns") is Dictionary or not jobs.get("order") is Array or not jobs.get("pickup") is bool: return false
	for key in ["completed", "attempts"]:
		if not number(jobs.get(key), 0, 1000000): return false
	if jobs.completed > jobs.attempts or not number(jobs.get("index"), 0, 3): return false
	for id in jobs.cooldowns:
		if not Game.jobs.catalog.has(id) or not number(jobs.cooldowns[id], 0, 2000000000): return false
	if not jobs.active.is_empty():
		if not Game.jobs.catalog.has(jobs.active.get("id")) or not number(jobs.active.get("token"), 1, int(jobs.attempts)) or not number(jobs.active.get("started"), 0, 2000000000): return false
		if jobs.active.id == "stock" and (jobs.order.size() != 3 or not "rice" in jobs.order or not "water" in jobs.order or not "soap" in jobs.order or jobs.index >= 3): return false
	for item in jobs.order:
		if not item is String or not item in ["rice", "water", "soap"]: return false
	var dialogue_keys: Array = []
	for id in Game.relationships.NPC_IDS:
		for choice in ["greet", "help", "interest"]: dialogue_keys.append(id + ":" + choice)
	if not bool_map(data.dialogue, dialogue_keys): return false
	for id in data.relationships:
		if not id in Game.relationships.NPC_IDS or not data.relationships[id] is Dictionary: return false
		for key in ["friendship", "trust", "romance"]:
			if not number(data.relationships[id].get(key), 0, 100): return false
	for id in data.greeted:
		if not id in Game.relationships.NPC_IDS or not number(data.greeted[id], 1, int(data.clock.day)): return false
	for id in data.quests:
		if not Game.quests.catalog.has(id) or not data.quests[id] is Array: return false
		for event in data.quests[id]:
			if not event in Game.quests.catalog[id].objectives: return false
	if not bool_map(data.claimed, Game.quests.catalog.keys()): return false
	var home: Dictionary = data.housing
	if not Game.housing.catalog.has(home.get("current")) or not bool_map(home.get("owned"), ["apartment"]): return false
	for key in ["next_rent", "arrears", "stored"]:
		if not number(home.get(key), 0, 1000000000): return false
	if not home.get("furniture") is Array or home.furniture.size() + home.stored > 12: return false
	var occupied: Array = []
	for entry in home.furniture:
		if not entry is Dictionary or entry.get("id") != "chair" or not number(entry.get("x"), 7, 18) or not number(entry.get("y"), 7, 14): return false
		if entry.x < 10 and entry.y < 11: return false
		var cell: Vector2i = Vector2i(int(entry.x), int(entry.y))
		if cell in occupied: return false
		occupied.append(cell)
	var world: Dictionary = data.world
	if not world.get("weather") in ["clear", "rain", "traffic"] or not world.get("pending") in ["", "rain", "traffic", "neighbour"]: return false
	for key in ["until", "next_check", "roll"]:
		if not number(world.get(key), 0, 2000000000): return false
	if not world.get("cooldowns") is Dictionary or not world.get("positions") is Dictionary: return false
	for id in world.cooldowns:
		if not Game.events.EVENTS.has(id) or not number(world.cooldowns[id], 0, 2000000000): return false
	for id in world.positions:
		if not id in Game.relationships.NPC_IDS or not world.positions[id] is Array or world.positions[id].size() != 2: return false
		for coordinate in world.positions[id]:
			if not (coordinate is int or coordinate is float) or not is_finite(float(coordinate)) or coordinate < 32 or coordinate > 1900: return false
	var character: Dictionary = data.character
	if not character.get("owned") is Array or character.owned.size() > Game.wardrobe.CLOTHES.size() or character.owned.is_empty(): return false
	var seen: Array = []
	for id in character.owned:
		if not Game.wardrobe.CLOTHES.has(id) or id in seen: return false
		seen.append(id)
	if not character.get("shirt") in character.owned: return false
	for part in ["skin", "hair", "shoes"]:
		if not number(character.get(part), 0, 2): return false
	if not character.get("phone_tab") in ["home", "bank", "contacts", "jobs", "map", "quests"] or not number(character.get("bank"), 0, 1000000000): return false
	return bool_map(data.achievements, ["First pay", "Reliable worker", "Professional", "Established"])

func migration_defaults() -> Dictionary:
	# Deterministic defaults; never copy an unrelated current session into an old save.
	return {"stats": {"cash": 5000, "energy": 100, "hunger": 100, "health": 100, "reputation": 0},
		"clock": {"day": 1, "hour": 7, "minute": 0}, "location": "room", "position": [448, 448],
		"inventory": {}, "jobs": {"active": {}, "cooldowns": {}, "completed": 0, "attempts": 0, "order": [], "index": 0, "pickup": false},
		"dialogue": {}, "relationships": {}, "greeted": {}, "quests": {}, "claimed": {},
		"housing": {"current": "room", "owned": {}, "next_rent": 8, "arrears": 0, "furniture": [], "stored": 1}, "achievements": {}, "world": {"weather": "clear", "until": 0, "pending": "", "cooldowns": {}, "next_check": 600, "roll": 0, "positions": {}}, "character": {"owned": ["green"], "shirt": "green", "skin": 1, "hair": 0, "shoes": 0, "phone_tab": "home", "bank": 0}}
func migrate(data: Variant) -> Variant:
	if data is Dictionary and data.get("version") in [1, 2]:
		# Version 1 used the same core stats/clock/location; later systems get defaults.
		var defaults: Dictionary = migration_defaults()
		for key in defaults:
			if not data.has(key): data[key] = defaults[key]
		data.version = VERSION
	return data

func apply(data: Dictionary) -> void:
	if is_instance_valid(Game.ui): Game.ui.close()
	else: Game.close_modal()
	Global.cash = int(data.stats.cash)
	Global.energy = int(data.stats.energy)
	Global.hunger = int(data.stats.hunger)
	Global.health = int(data.stats.health)
	Global.reputation = int(data.stats.reputation)
	TimeManager.current_day = int(data.clock.day)
	TimeManager.current_hour = int(data.clock.hour)
	TimeManager.current_minute = int(data.clock.minute)
	TimeManager.elapsed_seconds = 0
	Game.inventory.items = data.inventory.duplicate(true)
	Game.jobs.active = data.jobs.active.duplicate(true)
	Game.jobs.cooldowns = data.jobs.cooldowns.duplicate(true)
	Game.jobs.completed = int(data.jobs.completed)
	Game.jobs.attempts = int(data.jobs.attempts)
	Game.jobs.stock_order = data.jobs.order.duplicate()
	Game.jobs.stock_index = int(data.jobs.index)
	Game.jobs.delivery_checkpoint = data.jobs.pickup
	Game.jobs.delivery_received = false
	Game.dialogue.flags = data.dialogue.duplicate(true)
	Game.relationships.values = data.relationships.duplicate(true)
	Game.relationships.greeted_day = data.greeted.duplicate(true)
	Game.quests.objectives = data.quests.duplicate(true)
	Game.quests.claimed = data.claimed.duplicate(true)
	Game.housing.current = data.housing.current
	Game.housing.owned = data.housing.owned.duplicate(true)
	Game.housing.next_rent_day = int(data.housing.next_rent)
	Game.housing.arrears = int(data.housing.arrears)
	Game.housing.furniture = data.housing.furniture.duplicate(true)
	Game.housing.stored = int(data.housing.stored)
	Game.progression.achievements = data.achievements.duplicate(true)
	Game.events.state = data.world.duplicate(true)
	Game.wardrobe.state = data.character.duplicate(true)
	Game.wardrobe.changed.emit()
	Game.events.changed.emit()
	Game.scenes.location = data.location
	Game.scenes.pending_position = Vector2(float(data.position[0]), float(data.position[1]))
	Global.stats_changed.emit()
	TimeManager.time_changed.emit()
	Game.inventory.changed.emit()
	Game.scenes.location_changed.emit()

func write_save() -> bool:
	if not enabled: return false
	last_error = ""
	var state: Dictionary = snapshot()
	if not valid(state):
		last_error = "Current state failed save validation."
		return false
	var absolute: String = ProjectSettings.globalize_path(path)
	if DirAccess.make_dir_recursive_absolute(absolute.get_base_dir()) != OK:
		last_error = "Cannot create save directory."
		return false
	var file: FileAccess = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		last_error = "Cannot write save file."
		return false
	file.store_string(JSON.stringify(state))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		last_error = "Save write failed."
		return false
	if FileAccess.file_exists(path) and read_state(path) != null:
		if DirAccess.copy_absolute(absolute, absolute + ".bak") != OK:
			last_error = "Cannot preserve save backup."
			return false
	# Same-directory rename replaces the slot only after the temp file is complete.
	if DirAccess.rename_absolute(absolute + ".tmp", absolute) != OK:
		last_error = "Cannot replace save slot. Previous save retained."
		return false
	return true

func read_state(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path): return null
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null or file.get_length() > 2000000: return null
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK: return null
	var state: Variant = migrate(json.data)
	return state if valid(state) else null

func load_save() -> bool:
	var state: Variant = read_state(path)
	if state == null:
		state = read_state(path + ".bak")
		if state != null: Game.message("Recovered the previous save from backup.")
	if state == null:
		last_error = "No valid save found. Your current game was kept."
		return false
	apply(state)
	return true

func autosave() -> void:
	if not enabled: return
	if not write_save(): Game.message(last_error)

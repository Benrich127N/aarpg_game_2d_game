extends Node
var failures: int = 0
var checks: int = 0

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)

func find_button(node: Node, text: String) -> Button:
	if node is Button and node.text == text: return node
	for child in node.get_children():
		var found: Button = find_button(child, text)
		if found != null: return found
	return null

func press(text: String) -> bool:
	var control: Button = find_button(Game.ui.overlay, text)
	if control == null or control.disabled: return false
	control.pressed.emit()
	return true
func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.reset()
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(main)
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(Game.scenes.location == "room", "Fresh start in room")
	check(main.district.get_node("Ground") is TileMapLayer, "Tile map floor")
	Game.ui.perform("bed", "")
	check(Game.modal_open and Global.input_blocked, "Modal blocks player input")
	Game.ui.close()
	check(not Global.input_blocked, "Closing restores input")
	check(Game.scenes.travel("mainland", true), "Leave home")
	await get_tree().physics_frame
	check(get_tree().get_nodes_in_group("player").size() == 1, "Exactly one player after transition")
	var npcs: Array = []
	for node in get_tree().get_nodes_in_group("interactables"):
		if node.kind == "npc": npcs.append(node)
	check(npcs.size() == 5, "Five NPCs on mainland")
	main.get_node("Player").position = Vector2(320, 352)
	for physics_frame in range(3): await get_tree().physics_frame
	check(main.get_node("Player").test_move(main.get_node("Player").transform, Vector2(0, -100)), "Generated TileMapLayer building blocks the player")
	for key in [KEY_I, KEY_J, KEY_P, KEY_C]:
		var key_event := InputEventKey.new()
		key_event.keycode = key
		key_event.physical_keycode = key
		key_event.pressed = true
		get_viewport().push_input(key_event)
		check(Game.modal_open, "Physical keyboard shortcut opens menu")
		Game.ui.close()
	main.get_node("Player").position = Vector2(480, 720)
	for frame_index in range(3): await get_tree().physics_frame
	var interact_event := InputEventKey.new()
	interact_event.keycode = KEY_E
	interact_event.physical_keycode = KEY_E
	interact_event.pressed = true
	get_viewport().push_input(interact_event)
	await get_tree().process_frame
	check(Game.modal_open, "E opens nearby NPC dialogue through Area2D detection")
	Game.ui.close()
	interact_event = InputEventKey.new()
	interact_event.keycode = KEY_E
	interact_event.physical_keycode = KEY_E
	interact_event.pressed = false
	get_viewport().push_input(interact_event)
	for id in Game.relationships.NPC_IDS:
		Game.ui.dialogue(id)
		check(Game.modal_open, "Dialogue opens for " + id)
		check(Game.dialogue.choose(id, "greet"), "Greeting branch for " + id)
		check(Game.dialogue.choose(id, "help"), "Advice branch for " + id)
		check(Game.dialogue.flags.get(id + ":greet", false), "Persistent greeting flag")
	Game.ui.close()
	check(not Game.dialogue.choose("missing", "greet"), "Unknown NPC rejected")
	var friendship: int = Game.relationships.values.tunde.friendship
	Game.dialogue.choose("tunde", "greet")
	check(Game.relationships.values.tunde.friendship == friendship, "Greeting cannot be farmed same day")
	var detector: Area2D = main.get_node("Player/InteractionArea")
	var low: Area2D = load("res://scripts/world/Interactable.gd").new()
	low.title = "Low"
	low.position = Vector2(100, 100)
	main.add_child(low)
	var high: Area2D = load("res://scripts/world/Interactable.gd").new()
	high.interaction_priority = 20
	high.position = Vector2(105, 100)
	main.add_child(high)
	check(detector.choose([low, high]) == high, "Overlap priority is deterministic")
	low.queue_free()
	high.queue_free()
	check(not Game.jobs.start("stock"), "Stock job initially locked")
	Game.ui.job("delivery")
	check(press("Start job"), "Start button is usable")
	check(Game.jobs.active.get("id", "") == "delivery", "Start delivery through UI callback")
	Game.ui.close()
	var token: int = Game.jobs.active.token
	check(Global.energy == 90, "Job energy charged once")
	check(not Game.jobs.start("delivery"), "Concurrent job rejected")
	check(not Game.jobs.finish(token, true), "Unfinished delivery cannot claim pay")
	check(not Game.jobs.deliver_to("bisi"), "Parcel must be picked up")
	check(Game.jobs.pickup_parcel(), "Pick up parcel")
	check(not Game.jobs.deliver_to("tunde"), "Wrong recipient rejected")
	check(not Game.jobs.finish(token, true), "Pickup alone cannot complete delivery")
	check(Game.jobs.deliver_to("bisi"), "Deliver to Bisi")
	check(Global.cash == 5750, "Delivery pays correct reward")
	check(not Game.jobs.finish(token, true) and Global.cash == 5750, "Duplicate job completion rejected")
	check(not Game.jobs.start("delivery"), "Cooldown blocks immediate repeat")
	var before: int = Global.cash
	check(not Game.inventory.purchase("food", "pure_water"), "Shop catalog restriction")
	check(Game.inventory.purchase("food", "gala"), "Buy Gala")
	check(Global.cash == before - 200 and Game.inventory.items.gala == 1, "Atomic purchase")
	Global.hunger = 30
	check(Game.inventory.use_item("gala") and Global.hunger == 55, "Consume restores hunger")
	check(not Game.inventory.use_item("gala"), "Cannot consume absent item")
	check(not Game.inventory.add("gala", 9223372036854775807), "Oversized inventory count rejected")
	check(Game.inventory.add("gala", 10), "Fill stack")
	before = Global.cash
	check(not Game.inventory.purchase("food", "gala") and Global.cash == before, "Full stack leaves cash unchanged")
	Global.cash = 0
	check(not Game.inventory.purchase("food", "rice"), "Insufficient funds rejected")
	Global.cash = before
	check(Game.jobs.start("stock"), "Stock unlocked after delivery")
	Game.ui.job("stock")
	Game.ui.close()
	var wrong: String = "soap" if Game.jobs.stock_order[0] != "soap" else "rice"
	before = Global.cash
	check(not Game.jobs.match_stock(wrong) and Game.jobs.active.is_empty() and Global.cash == before, "Wrong stock match fails without pay")
	TimeManager.advance_minutes(300)
	check(Game.jobs.start("stock"), "Stock cooldown expires")
	var sequence: Array = Game.jobs.stock_order.duplicate()
	for item in sequence:
		Game.ui.job("stock")
		check(press("Stock " + str(item).capitalize()), "Stock button selects correct item")
	Game.ui.close()
	check(Global.cash == before + 1200 and Game.jobs.completed == 2, "Correct stock sequence pays once")
	check(not Game.jobs.match_stock("rice"), "No replay after stock completion")
	check(Game.scenes.travel("room", true), "Return home")
	check(Game.housing.sleep(), "Sleep completes daily loop")
	check(Global.energy == 100 and TimeManager.current_hour == 7 and TimeManager.current_day == 2, "Sleep advances morning")
	check(Game.quests.claim("first_day"), "First-day quest reward")
	before = Global.cash
	check(not Game.quests.claim("first_day") and Global.cash == before, "Quest reward cannot repeat")
	check(Game.quests.eligible("neighbour"), "Quest chain prerequisite unlocks")
	Game.ui.journal()
	Game.ui.contacts()
	Game.ui.career()
	Game.ui.housing()
	Game.ui.furniture()
	Game.ui.bag()
	Game.ui.close()
	check(Game.housing.place_chair(Vector2i(12, 9)), "Place chair on room grid")
	check(not Game.housing.place_chair(Vector2i(12, 9)), "No overlapping furniture")
	check(not Game.housing.place_chair(Vector2i(8, 8)), "Bed approach protected")
	check(Game.housing.store_chair() and Game.housing.stored == 1, "Furniture storage")
	check(Game.housing.place_chair(Vector2i(15, 9)), "Replace furniture")
	Game.housing.on_day(8)
	check(Game.housing.arrears == 700, "Weekly rent invoice")
	Game.housing.on_day(8)
	check(Game.housing.arrears == 700, "Rent not charged twice")
	check(Game.housing.pay_rent(), "Settle rent")
	check(Game.scenes.travel("mainland", true), "Leave home for travel")
	before = Global.cash
	check(not Game.scenes.travel("business") and Global.cash == before, "District lock does not charge")
	Global.cash = 40000
	Game.jobs.completed = 5
	Game.jobs.attempts = 5
	Global.reputation = 10
	check(Game.progression.tier() == 1, "All professional thresholds met")
	Global.reputation = 9
	check(Game.progression.tier() == 0, "Reputation independently gates progression")
	Global.reputation = 10
	check(Game.scenes.travel("business"), "Business travel unlocked")
	check(Global.cash == 39700, "Travel fare charged once")
	check(Game.scenes.travel("lekki"), "Lekki prototype loads")
	Global.cash = 150000
	Global.reputation = 40
	Game.jobs.completed = 10
	Game.jobs.attempts = 10
	check(Game.scenes.travel("island"), "Island prototype loads")
	check(get_tree().get_nodes_in_group("player").size() == 1, "Single player across districts")
	check(Game.scenes.travel("mainland"), "Return from district")
	check(Game.scenes.travel("room", true), "Reenter home")
	check(Game.housing.buy("apartment"), "Purchase apartment")
	check(Game.progression.net_worth() == Global.cash + 30000, "Property counted separately in net worth")
	check(not Game.housing.buy("apartment"), "Cannot repurchase owned property")
	Game.housing.on_day(50)
	check(Game.housing.arrears == 0, "Owned home has no rent")
	Game.relationships.values.bisi.friendship = 20
	check(Game.dialogue.choose("bisi", "interest"), "Optional romance branch")
	Game.quests.record("talk:bisi")
	Game.quests.record("job")
	check(Game.quests.claim("neighbour"), "Second quest reward")
	# Files are isolated inside ignored project cache, never the player's slot.
	Game.save.path = "res://.godot/integration/slot.json"
	Game.save.enabled = true
	check(Game.save.valid(Game.save.snapshot()), "Full state validates")
	check(Game.save.write_save(), "Save writes temp file and renames")
	check(Game.save.write_save(), "Existing save replaced with backup")
	var state: Dictionary = Game.save.snapshot()
	Game.reset()
	check(Game.save.load_save(), "Reload saved state")
	check(Global.cash == state.stats.cash and Game.housing.current == "apartment", "Cash and property restored")
	check(Game.housing.furniture.size() == 1 and Game.dialogue.flags.get("bisi:interest", false), "Furniture and dialogue restored")
	check(Game.quests.claimed.get("neighbour", false) and Game.relationships.values.bisi.romance == 5, "Quest and relationship persistence")
	var broken: Dictionary = state.duplicate(true)
	broken.stats.cash = -10
	check(not Game.save.valid(broken), "Invalid cash rejected before mutation")
	broken = state.duplicate(true)
	broken.clock.hour = 25
	check(not Game.save.valid(broken), "Invalid clock rejected")
	broken = state.duplicate(true)
	broken.inventory = {"unknown": 1}
	check(not Game.save.valid(broken), "Unknown saved item rejected")
	broken = state.duplicate(true)
	broken.version = 999
	check(not Game.save.valid(broken), "Future schema rejected")
	var corrupt: FileAccess = FileAccess.open(Game.save.path, FileAccess.WRITE)
	corrupt.store_string("not json")
	corrupt.close()
	check(Game.save.load_save(), "Corrupt slot recovers backup")
	Game.save.path = "res://.godot/integration/missing.json"
	before = Global.cash
	check(not Game.save.load_save() and Global.cash == before, "Missing save leaves current state unchanged")
	Game.save.enabled = false
	var old_save: Dictionary = {"version": 1, "stats": state.stats.duplicate(), "clock": state.clock.duplicate(), "inventory": {}, "location": "room", "position": [448,448]}
	var migrated: Variant = Game.save.migrate(old_save)
	check(Game.save.valid(migrated) and migrated.housing.current == "room" and migrated.jobs.completed == 0, "Old save migration uses clean defaults")
	var before_interest: int = Game.relationships.values.bisi.romance
	check(not Game.dialogue.choose("bisi", "interest") and Game.relationships.values.bisi.romance == before_interest, "Romance branch cannot be farmed")
	for final_frame in range(3): await get_tree().process_frame
	print("STEPS 6–15: %s · %d checks" % ["PASS" if failures == 0 else "FAIL (%d)" % failures, checks])
	get_tree().quit(0 if failures == 0 else 1)

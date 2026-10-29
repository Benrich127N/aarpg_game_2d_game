extends CanvasLayer
var overlay: ColorRect
var content: VBoxContainer
var heading: Label
var body: VBoxContainer
var first_button: Button
var status_label: Label
var last_notice: String = ""
var title_mode: bool = false
var phone_view: Node
var settings_view: Node

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.ui = self
	phone_view = preload("res://Scenes/ui/PhoneUI.tscn").instantiate()
	add_child(phone_view)
	settings_view = preload("res://Scenes/ui/SettingsMenu.tscn").instantiate()
	add_child(settings_view)
	Game.settings.changed.connect(_apply_settings)
	overlay = ColorRect.new()
	overlay.color = Color(0.025, 0.045, 0.035, 0.94)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + edge, 60)
	overlay.add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	overlay.hide()
	Game.message_sent.connect(_message)
	_apply_settings()

func _exit_tree() -> void:
	if Game.ui == self: Game.ui = null

func _input(event: InputEvent) -> void:
	if Game.modal_open:
		if event.is_action_pressed("pause"):
			close()
			get_viewport().set_input_as_handled()
		return
	if get_tree().paused or title_mode: return
	for binding in [["phone", "phone"], ["wardrobe", "wardrobe"], ["inventory", "bag"], ["journal", "journal"], ["contacts", "contacts"], ["career", "career"]]:
		if event.is_action_pressed(binding[0]):
			perform(binding[1], "")
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("save_game"):
		manual_save()
		get_viewport().set_input_as_handled()

func frame(title: String, description: String = "") -> void:
	if not Game.modal_open: last_notice = ""
	Game.open_modal()
	overlay.show()
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	first_button = null
	heading = Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size", int(28 * float(Game.settings.values.text_scale)))
	content.add_child(heading)
	status_label = Label.new()
	status_label.text = last_notice
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("e8c779"))
	status_label.visible = not last_notice.is_empty()
	content.add_child(status_label)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	content.add_child(body)
	if not description.is_empty(): line(description)
	button("Close · Esc", close)

func line(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(label)

func button(text: String, action: Callable, disabled: bool = false) -> Button:
	var control := Button.new()
	control.text = text
	control.custom_minimum_size.y = 42
	control.disabled = disabled
	control.pressed.connect(func() -> void: Game.audio.sfx("click"))
	control.pressed.connect(action)
	body.add_child(control)
	if first_button == null and not disabled:
		first_button = control
		call_deferred("_focus_first")
	return control

func _focus_first() -> void:
	if is_instance_valid(first_button) and first_button.is_inside_tree() and overlay.visible:
		first_button.grab_focus()

func close() -> void:
	if title_mode:
		title_screen()
		return
	overlay.hide()
	Game.close_modal()

func _message(text: String) -> void:
	last_notice = text
	if Game.modal_open and is_instance_valid(status_label):
		status_label.text = text
		status_label.show()
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null: hud.notify(text)

func set_prompt(text: String) -> void:
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null: hud.set_interaction_prompt(text)

func result(success: bool, good: String = "Done.", failure: String = "That action is unavailable. Check cash, space, or requirements.") -> void:
	Game.message(good if success else failure)

func perform(kind: String, id: String) -> void:
	match kind:
		"npc": dialogue(id)
		"shop": shop(id)
		"job": job(id)
		"parcel":
			result(Game.jobs.pickup_parcel(), "Parcel collected. Take it to Bisi beside the kiosk.")
		"door":
			close()
			Game.scenes.travel(id, true)
		"bed":
			frame("Rest until tomorrow", "Sleep advances to 07:00 tomorrow and restores energy. Hunger still decreases overnight.")
			button("Sleep and save", func() -> void:
				if Game.housing.sleep():
					close()
					Game.save.autosave())
		"travel": travel()
		"housing": housing()
		"furniture": furniture()
		"bag": bag()
		"journal": journal()
		"contacts": contacts()
		"career": career()
		"phone": phone_view.show_tab(Game.wardrobe.state.phone_tab)
		"wardrobe": wardrobe()
		"clothes": clothing_shop()

func dialogue(id: String) -> void:
	if not Game.dialogue.data.has(id): return
	var data: Dictionary = Game.dialogue.data[id]
	frame(data.name + " · " + data.role, data.greeting)
	button("Greet warmly", func() -> void:
		Game.dialogue.choose(id, "greet")
		frame(data.name, "Good to see you again." if int(Game.relationships.greeted_day.get(id, 0)) == TimeManager.current_day else "Hello!")
		line("Friendship: %d · Trust: %d" % [int(Game.relationships.values.get(id, {}).get("friendship", 0)), int(Game.relationships.values.get(id, {}).get("trust", 0))]))
	button("Ask for advice", func() -> void:
		Game.dialogue.choose(id, "help")
		frame(data.name, data.help))
	if id == "tunde": button("Ask about delivery work", func() -> void: job("delivery"))
	if id == "femi": button("Ask about stock work", func() -> void: job("stock"))
	if id == "amara": button("Browse food", func() -> void: shop("food"))
	if id == "sade": button("Browse provisions", func() -> void: shop("kiosk"))
	if id == "bisi":
		if Game.jobs.active.get("id", "") == "delivery":
			button("Hand over parcel", func() -> void:
				if Game.jobs.deliver_to("bisi"):
					close()
					Game.save.autosave()
				else: Game.message("Collect the parcel beside Tunde first."))
		button("Express interest (optional)", func() -> void:
			if Game.dialogue.choose(id, "interest"):
				frame("Bisi", "I'd like to spend more time together too.")
			else:
				frame("Bisi", "Let's get to know each other first. Friendship 20 is required."))

func job(id: String) -> void:
	if not Game.jobs.catalog.has(id): return
	var data: Resource = Game.jobs.catalog[id]
	frame(data.title, "Pay ₦%d · Energy %d · Duration %d minutes" % [data.pay, data.energy, data.minutes])
	if Game.jobs.active.get("id", "") == id:
		if id == "stock":
			var minigame: VBoxContainer = preload("res://Scenes/minigames/StockMinigame.tscn").instantiate()
			minigame.selected.connect(func(item: String) -> void:
				Game.jobs.match_stock(item)
				if Game.jobs.active.is_empty():
					close()
					Game.save.autosave()
				else: job(id))
			body.add_child(minigame)
		else:
			var minigame: VBoxContainer = preload("res://Scenes/minigames/DeliveryMinigame.tscn").instantiate()
			minigame.cancelled.connect(func() -> void:
				Game.jobs.cancel()
				close())
			body.add_child(minigame)
		if id == "stock": button("Cancel shift · no pay", func() -> void:
			Game.jobs.cancel()
			close())
	else:
		var blocked: String = Game.jobs.reason(id)
		if not blocked.is_empty(): line(blocked)
		button("Start job", func() -> void:
			if Game.jobs.start(id): job(id), not blocked.is_empty())

func shop(id: String) -> void:
	if not Game.inventory.SHOP_ITEMS.has(id): return
	frame("Food stall" if id == "food" else "Provisions kiosk", "Cash: ₦%d · Buy one item at a time. Use I to open your bag." % Global.cash)
	for item_id in Game.inventory.SHOP_ITEMS[id]:
		var item: Resource = Game.inventory.catalog[item_id]
		button("%s · ₦%d · +%d hunger" % [item.title, item.price, item.hunger], func() -> void:
			result(Game.inventory.purchase(id, item_id), "Purchased " + item.title)
			shop(id))

func bag() -> void:
	frame("Your bag", "Food restores hunger satisfaction. Higher is better.")
	if Game.inventory.items.is_empty(): line("Your bag is empty. Visit Amara or Sade.")
	for id in Game.inventory.items.keys():
		var item: Resource = Game.inventory.catalog[id]
		button("Eat / drink %s × %d" % [item.title, Game.inventory.items[id]], func() -> void:
			Game.inventory.use_item(id)
			bag())
	if not Game.jobs.active.is_empty(): button("Current job", func() -> void: job(Game.jobs.active.id))

func travel() -> void:
	frame("Bus stop", "Transport charges cash and advances time. Home is reached through the mainland street door.")
	for id in ["mainland", "business", "lekki", "island"]:
		var destination: Dictionary = Game.scenes.DESTINATIONS[id]
		var locked: bool = Game.progression.tier() < int(destination.tier)
		button("%s · ₦%d · %d min%s" % [destination.title, destination.fare, destination.minutes, " · locked" if locked else ""], func() -> void:
			close()
			Game.scenes.travel(id), locked or id == Game.scenes.location)

func housing() -> void:
	frame("Housing desk", "Home: %s · Rent due day %d · Arrears ₦%d" % [Game.housing.catalog[Game.housing.current].title, Game.housing.next_rent_day, Game.housing.arrears])
	button("Pay rent arrears", func() -> void:
		result(Game.housing.pay_rent())
		housing(), Game.housing.arrears == 0)
	button("Rent courtyard apartment · ₦2,500 / week", func() -> void:
		result(Game.housing.rent("apartment"))
		housing())
	button("Move to mainland room · ₦700 / week", func() -> void:
		result(Game.housing.rent("room"))
		housing())
	button("Buy courtyard apartment · ₦30,000", func() -> void:
		result(Game.housing.buy("apartment"))
		housing())

func furniture() -> void:
	frame("Furniture", "Stored chairs: %d · Placed: %d\nChoose a position on the room's 32-pixel grid. Your bed and doorway stay clear." % [Game.housing.stored, Game.housing.furniture.size()])
	button("Buy a chair · ₦400", func() -> void:
		result(Game.housing.buy_chair())
		furniture())
	for spot in [Vector2i(12, 9), Vector2i(15, 9), Vector2i(18, 12), Vector2i(12, 14)]:
		button("Place chair at (%d, %d)" % [spot.x, spot.y], func() -> void:
			result(Game.housing.place_chair(spot))
			furniture())
	button("Store last chair", func() -> void:
		result(Game.housing.store_chair())
		furniture())

func journal() -> void:
	frame("Quest journal")
	for id in Game.quests.catalog:
		var data: Resource = Game.quests.catalog[id]
		line(data.title + (" · claimed" if bool(Game.quests.claimed.get(id, false)) else ""))
		line(data.description)
		if not Game.quests.eligible(id):
			line("Requires: " + data.prerequisite)
			continue
		var done: Array = Game.quests.objectives.get(id, [])
		for objective in data.objectives: line(("✓ " if objective in done else "○ ") + objective)
		button("Claim ₦%d reward" % data.reward, func() -> void:
			result(Game.quests.claim(id), "Quest reward collected.", "Complete every objective before claiming this reward.")
			journal(), bool(Game.quests.claimed.get(id, false)))
	if not Game.jobs.active.is_empty(): button("Current job / cancel", func() -> void: job(Game.jobs.active.id))

func contacts() -> void:
	frame("Phone · contacts", "Relationships grow once per greeting per game day.")
	for id in Game.relationships.NPC_IDS:
		if not Game.dialogue.flags.has(id + ":greet") and not Game.dialogue.flags.has(id + ":help"): continue
		var entry: Dictionary = Game.relationships.values.get(id, {})
		line("%s · Friendship %d · Trust %d · Interest %d" % [Game.dialogue.data[id].name, entry.get("friendship", 0), entry.get("trust", 0), entry.get("romance", 0)])

func career() -> void:
	frame("Career and finances", "%s · Cash ₦%d · Net worth ₦%d · Reputation %d\nCompleted jobs: %d" % [Game.progression.title(), Global.cash, Game.progression.net_worth(), Global.reputation, Game.jobs.completed])
	line("Professional: net worth ₦12,000, reputation 10, 3 jobs.\nEstablished: net worth ₦100,000, reputation 40, 10 jobs.")
	for achievement in Game.progression.achievements: line("★ " + achievement)
	button("Current job", func() -> void: job(Game.jobs.active.id), Game.jobs.active.is_empty())

func manual_save() -> void:
	result(Game.save.write_save(), "Game saved.")
	if not Game.save.last_error.is_empty(): Game.message(Game.save.last_error)

func manual_load() -> void:
	close()
	result(Game.save.load_save(), "Save loaded.")

func new_game_prompt() -> void:
	frame("Start a new game?", "This resets the current session. Your saved slot is replaced only when you next save or autosave.")
	button("Start fresh", func() -> void:
		close()
		Game.reset()
		Game.scenes.location_changed.emit())

func _apply_settings() -> void:
	if not is_instance_valid(overlay): return
	var theme := Theme.new()
	theme.default_font_size = int(18 * float(Game.settings.values.text_scale))
	overlay.theme = theme

func settings_menu() -> void:
	settings_view.show_panel()

func wardrobe() -> void:
	frame("Wardrobe", "Your owned shirts and free character options. Buy more colours at the mainland clothing stall.")
	if is_instance_valid(Game.player):
		var preview := Control.new()
		preview.custom_minimum_size = Vector2(0, 144)
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		body.add_child(preview)
		for layer in Game.player.layers:
			var image := TextureRect.new()
			image.texture = layer.sprite_frames.get_frame_texture("idle_down", 0)
			image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
			image.offset_left = -48
			image.offset_right = 48
			image.offset_bottom = 144
			image.mouse_filter = Control.MOUSE_FILTER_IGNORE
			preview.add_child(image)
	for id in Game.wardrobe.state.owned:
		button("Wear " + str(Game.wardrobe.CLOTHES[id].title) + (" · equipped" if Game.wardrobe.state.shirt == id else ""), func() -> void:
			Game.wardrobe.equip(id)
			wardrobe())
	for part in ["skin", "hair", "shoes"]:
		button("%s style %d · change" % [part.capitalize(), int(Game.wardrobe.state[part]) + 1], func() -> void:
			Game.wardrobe.customize(part, (int(Game.wardrobe.state[part]) + 1) % 3)
			wardrobe())

func clothing_shop() -> void:
	frame("Clothing stall", "Cash ₦%d · Owned outfits remain available in your wardrobe (O)." % Global.cash)
	for id in Game.wardrobe.CLOTHES:
		if id == "green": continue
		button("%s · ₦%d%s" % [Game.wardrobe.CLOTHES[id].title, Game.wardrobe.CLOTHES[id].price, " · owned" if id in Game.wardrobe.state.owned else ""], func() -> void:
			result(Game.wardrobe.buy(id), "Shirt purchased.")
			clothing_shop(), id in Game.wardrobe.state.owned)
	button("Open wardrobe", wardrobe)

func event_panel() -> void:
	var id: String = Game.events.state.pending
	if not Game.events.EVENTS.has(id):
		frame("Neighbourhood", "No pending event. Explore the street and check back later.")
		return
	var data: Dictionary = Game.events.EVENTS[id]
	frame(data.title, data.text)
	button("Help" if id == "neighbour" else "Wait it out", func() -> void:
		result(Game.events.resolve(true), "Thanks for taking a moment.")
		event_panel())
	button("Carry on", func() -> void:
		Game.events.resolve(false)
		close())

func credits() -> void:
	frame("Credits", "PH NIGHT · Prototype\nA fictional neighbourhood life sim.\nOriginal procedural character layers, environment shapes, icon, sound design, syncopated music cue and dialogue were created for this project.\nBuilt with Godot Engine (MIT licence). The licence and third-party engine notices are included with the release.\nThe earlier unverified prototype sprite is excluded from release packages.")

func title_screen() -> void:
	frame("PH NIGHT", "One street. A fresh start. Build your day, one choice at a time.")
	# A title screen has no gameplay behind it to close into.
	for child in body.get_children():
		if child is Button and child.text == "Close · Esc":
			body.remove_child(child)
			child.queue_free()
	first_button = null
	button("Continue", func() -> void: start_game(false), Game.save.read_state(Game.save.path) == null and Game.save.read_state(Game.save.path + ".bak") == null)
	button("New game", func() -> void:
		frame("Start fresh?", "Your previous save stays on disk until the next manual save or autosave.")
		button("Start new game", func() -> void: start_game(true)))
	button("Settings", settings_menu)
	button("Credits", credits)
	button("Quit", func() -> void: get_tree().quit())

func start_game(fresh: bool) -> void:
	title_mode = false
	close()
	get_tree().paused = false
	if fresh:
		Game.reset()
		Game.booted = true
	else:
		Game.booted = false
		Game.auto_load = true
	get_tree().change_scene_to_file("res://Scenes/main/Main.tscn")

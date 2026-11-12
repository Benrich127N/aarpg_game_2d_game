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
var title_page: Control
var dialogue_card: Control
const PIXEL_THEME = preload("res://scripts/ui/PixelMenuTheme.gd")
var page_backdrop: Control
var page_art: Control
var page_margin: MarginContainer
var page_panel: PanelContainer
var page_scroll: ScrollContainer
var back_button: Button

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
	page_backdrop = preload("res://scripts/ui/MenuBackdrop.gd").new()
	page_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(page_backdrop)
	page_backdrop.hide()
	page_art = preload("res://scripts/ui/MenuPageArt.gd").new()
	page_art.anchor_right = 0.31
	page_art.anchor_bottom = 1.0
	page_art.offset_left = 44
	page_art.offset_right = -12
	page_art.offset_top = 54
	page_art.offset_bottom = -48
	overlay.add_child(page_art)
	page_art.hide()
	var margin := MarginContainer.new()
	page_margin = margin
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + edge, 60)
	overlay.add_child(margin)
	page_panel = PanelContainer.new()
	page_panel.add_theme_stylebox_override("panel", PIXEL_THEME.box(Color("182d25"), Color("a99a6a"), 22))
	margin.add_child(page_panel)
	var scroll := ScrollContainer.new()
	page_scroll = scroll
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	page_panel.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	overlay.hide()
	dialogue_card = preload("res://scripts/ui/DialogueCard.gd").new()
	add_child(dialogue_card)
	Game.message_sent.connect(_message)
	_apply_settings()

func _exit_tree() -> void:
	if Game.ui == self: Game.ui = null

func _input(event: InputEvent) -> void:
	if Game.modal_open:
		if event.is_action_pressed("pause"):
			close()
			get_viewport().set_input_as_handled()
		elif is_instance_valid(dialogue_card) and dialogue_card.visible and dialogue_card.handle_input(event):
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
	_hide_dialogue()
	if is_instance_valid(title_page): title_page.hide()
	if not Game.modal_open: last_notice = ""
	Game.open_modal()
	var illustrated := title_mode or title == "Settings"
	page_backdrop.visible = illustrated
	page_art.visible = illustrated
	if illustrated: page_art.present(title)
	var confirmation := title_mode and title.begins_with("Start")
	page_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER if confirmation else Control.SIZE_EXPAND_FILL
	page_panel.custom_minimum_size.y = roundi(300 * float(Game.settings.values.text_scale)) if confirmation else 0
	page_margin.add_theme_constant_override("margin_left", 440 if illustrated else 60)
	page_margin.add_theme_constant_override("margin_right", 36 if illustrated else 60)
	page_margin.add_theme_constant_override("margin_top", 36 if illustrated else 60)
	page_margin.add_theme_constant_override("margin_bottom", 36 if illustrated else 60)
	page_scroll.scroll_vertical = 0
	overlay.show()
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	first_button = null
	heading = Label.new()
	heading.text = title
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_color_override("font_color", Color("f5dfa6"))
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
	back_button = button("← Back · Esc" if title_mode else "Close · Esc", close)
	first_button = null # The next enabled action is the page's primary action.

func line(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(label)

func button(text: String, action: Callable, disabled: bool = false) -> Button:
	var control := Button.new()
	control.text = text
	control.custom_minimum_size.y = 42
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	control.disabled = disabled
	if title_mode and text == "Start new game":
		control.add_theme_stylebox_override("normal", PIXEL_THEME.box(Color("d9b96f"), Color("efdaa0")))
		control.add_theme_stylebox_override("hover", PIXEL_THEME.box(Color("ecd092"), Color("fff0cc")))
		control.add_theme_stylebox_override("pressed", PIXEL_THEME.box(Color("b99a54"), Color("fff0cc")))
		for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
			control.add_theme_color_override(state, Color("17271f"))
	control.pressed.connect(func() -> void: Game.audio.sfx("click"))
	control.pressed.connect(action)
	body.add_child(control)
	PIXEL_THEME.decorate(control)
	if first_button == null and not disabled:
		first_button = control
		call_deferred("_focus_first")
	return control

func _focus_first() -> void:
	# Containers can change height after adding previews or the landmark diagram.
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(first_button): first_button = back_button
	if is_instance_valid(first_button) and first_button.is_inside_tree() and overlay.visible:
		first_button.grab_focus()
		page_scroll.ensure_control_visible(first_button)
		if first_button == back_button: page_scroll.scroll_vertical = 0

func close() -> void:
	if title_mode:
		title_screen()
		return
	if is_instance_valid(title_page): title_page.hide()
	overlay.hide()
	_hide_dialogue()
	Game.close_modal()
	if get_tree().paused:
		var hud: Node = get_tree().get_first_node_in_group("hud")
		if hud != null and hud.pause_overlay.visible: hud.pause_menu.refresh()

func _hide_dialogue() -> void:
	if is_instance_valid(dialogue_card): dialogue_card.hide()
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null: hud.set_dialogue_active(false)

func _message(text: String) -> void:
	last_notice = text
	if is_instance_valid(dialogue_card) and dialogue_card.visible:
		dialogue_card.show_notice(text)
	elif Game.modal_open and is_instance_valid(status_label):
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
		"venue_person": venue_person(id)
		"place": place(id)
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

func venue_person(id: String) -> void:
	var cast: Dictionary = preload("res://scripts/characters/VenueCast.gd").PEOPLE
	if not cast.has(id): return
	var options: Array = []
	var text: String = cast[id].greeting
	match id:
		"nneka":
			options.append({"text": "Ask about bar work", "action": func() -> void: job("club")})
			options.append({"text": "Ask about the neighborhood", "action": func() -> void: _venue_reply(id, "Bisi is planning a community garden. Sade's shop has supplies, and Amara's tables are a good place to stop for food.")})
		"kemi":
			options.append({"text": "Ask about dancing", "action": func() -> void: place("dance")})
			options.append({"text": "Ask where to eat", "action": func() -> void: _venue_reply(id, "Try Amara's stall on the north side of the street. Her outdoor tables are south of the stall, between the courtyard and club.")})
		"dele":
			options.append({"text": "Head to the dance floor", "action": func() -> void: place("dance")})
	options.append({"text": "Goodbye", "action": close})
	_venue_card(id, text, options)

func _venue_card(id: String, text: String, options: Array) -> void:
	Game.open_modal()
	overlay.hide()
	dialogue_card.open(self, id, text, options, preload("res://scripts/characters/VenueCast.gd").PEOPLE[id])
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null: hud.set_dialogue_active(true)

func _venue_reply(id: String, text: String) -> void:
	_venue_card(id, text, [{"text": "Back to conversation", "action": func() -> void: venue_person(id)}, {"text": "Goodbye", "action": close}])

func place(id: String) -> void:
	match id:
		"garden":
			frame("Bisi's garden plan", "The noticeboard shows raised vegetable beds, shaded benches and a clear path through the courtyard. Bisi wants this to be a place where neighbors can spend time together.")
			button("Talk to Bisi", func() -> void: dialogue("bisi"))
		"bench":
			frame("Courtyard bench", "Take a quiet break beside the garden, or eat something from your bag.")
			button("Sit for 15 minutes · +5 energy", func() -> void: _venue_break(15, 5))
			button("Open food bag", bag)
		"cafe":
			frame("Amara's outdoor tables", "A shady spot for a meal between jobs. Buy food from Amara, then eat from your bag.")
			button("Browse Amara's food", func() -> void: shop("food"))
			button("Eat from your bag", bag)
			button("Sit for 15 minutes · +5 energy", func() -> void: _venue_break(15, 5))
		"dance":
			frame("PH Night · dance floor", "Take a break from work and enjoy the music. Dancing takes 10 minutes and 5 energy.")
			button("Dance for 10 minutes", func() -> void:
				if Global.energy < 5:
					Game.message("Rest or eat before dancing. You need 5 energy.")
					return
				_venue_break(10, -5))

func _venue_break(minutes: int, energy: int) -> void:
	Global.change_energy(energy)
	TimeManager.advance_minutes(minutes)
	close()
	Game.message("You took a quiet break." if energy > 0 else "You spent some time dancing to the music.")
	Game.save.autosave()

func _npc_card(id: String, text: String, options: Array) -> void:
	if is_instance_valid(title_page): title_page.hide()
	Game.open_modal()
	overlay.hide()
	dialogue_card.open(self, id, text, options)
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null: hud.set_dialogue_active(true)

func _npc_reply(id: String, text: String) -> void:
	_npc_card(id, text, [
		{"text": "Back to conversation", "action": func() -> void: dialogue(id)},
		{"text": "Goodbye", "action": close},
	])

func dialogue(id: String) -> void:
	if not Game.dialogue.data.has(id): return
	var data: Dictionary = Game.dialogue.data[id]
	var options: Array = [
		{"text": "Greet warmly", "action": func() -> void:
			Game.dialogue.choose(id, "greet")
			_npc_reply(id, "Good to see you again! Friendship: %d · Trust: %d" % [int(Game.relationships.values.get(id, {}).get("friendship", 0)), int(Game.relationships.values.get(id, {}).get("trust", 0))])},
		{"text": "Ask for advice", "action": func() -> void:
			Game.dialogue.choose(id, "help")
			_npc_reply(id, data.help)},
	]
	if id == "tunde": options.append({"text": "Ask about delivery work", "action": func() -> void: job("delivery")})
	if id == "femi": options.append({"text": "Ask about stock work", "action": func() -> void: job("stock")})
	if id == "amara": options.append({"text": "Browse food", "action": func() -> void: shop("food")})
	if id == "sade": options.append({"text": "Browse provisions", "action": func() -> void: shop("kiosk")})
	if id == "bisi":
		if Game.jobs.active.get("id", "") == "delivery":
			options.append({"text": "Hand over parcel", "action": func() -> void:
				if Game.jobs.deliver_to("bisi"):
					close()
					Game.save.autosave()
				else: _npc_reply(id, "Collect the parcel beside Tunde first.")})
		options.append({"text": "Express interest (optional)", "action": func() -> void:
			if Game.dialogue.choose(id, "interest"):
				_npc_reply(id, "I'd like to spend more time together too.")
			else:
				_npc_reply(id, "Let's get to know each other first. Friendship 20 is required.")})
	_npc_card(id, data.greeting, options)

func job(id: String) -> void:
	if not Game.jobs.catalog.has(id): return
	var data: Resource = Game.jobs.catalog[id]
	frame(data.title, "Pay ₦%d · Energy %d · Duration %d minutes" % [data.pay, data.energy, data.minutes])
	if Game.jobs.active.get("id", "") == id:
		if id == "club":
			line("Serve each guest's requested drink. A wrong drink ends the shift without pay.")
			line("Guest %d / 3 requests: %s" % [Game.jobs.stock_index + 1, str(Game.jobs.stock_order[Game.jobs.stock_index]).capitalize()])
			for drink in ["water", "juice", "soda"]:
				button("Serve " + drink.capitalize(), func() -> void:
					Game.jobs.serve_club(drink)
					if Game.jobs.active.is_empty():
						close()
						Game.save.autosave()
					else: job(id))
		elif id == "stock":
			var minigame: VBoxContainer = preload("res://Scenes/minigames/StockMinigame.tscn").instantiate()
			minigame.selected.connect(func(item: String) -> void:
				Game.jobs.match_stock(item)
				if Game.jobs.active.is_empty():
					close()
					Game.save.autosave()
				else: job(id))
			body.add_child(minigame)
			for child in minigame.get_children():
				if child is Button and not child.disabled:
					first_button = child
					call_deferred("_focus_first")
					break
		else:
			var minigame: VBoxContainer = preload("res://Scenes/minigames/DeliveryMinigame.tscn").instantiate()
			minigame.cancelled.connect(func() -> void:
				Game.jobs.cancel()
				close())
			body.add_child(minigame)
			first_button = back_button # Delivery continues in the world, not by cancelling.
		if id in ["stock", "club"]: button("Cancel shift · no pay", func() -> void:
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
	var directions := {"tunde": "Find Tunde by the parcel stand south of the food stall.", "amara": "Find Amara at the food stall on the north side of the mainland.", "sade": "Find Sade inside her provisions shop or near its street frontage.", "bisi": "Find Bisi in the community courtyard or along the north-side street.", "femi": "Find Femi inside the stockroom or at the stock stand east of the parcel stand."}
	for id in Game.relationships.NPC_IDS:
		if not Game.dialogue.flags.has(id + ":greet") and not Game.dialogue.flags.has(id + ":help"): continue
		var entry: Dictionary = Game.relationships.values.get(id, {})
		line("%s · Friendship %d · Trust %d · Interest %d" % [Game.dialogue.data[id].name, entry.get("friendship", 0), entry.get("trust", 0), entry.get("romance", 0)])
		line(directions[id])

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
	var theme := PIXEL_THEME.make(float(Game.settings.values.text_scale))
	overlay.theme = theme
	if is_instance_valid(page_art): page_art.apply_scale(float(Game.settings.values.text_scale))
	if is_instance_valid(title_page): title_page.apply_scale(float(Game.settings.values.text_scale))
	if is_instance_valid(dialogue_card): dialogue_card.apply_scale(float(Game.settings.values.text_scale))

func settings_menu() -> void:
	settings_view.show_panel("audio")

func wardrobe(focus_part: String = "") -> void:
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
	var labels := {"skin": "Skin tone", "hair": "Hair color", "shoes": "Shoe color"}
	var choices := {"skin": ["Warm tan", "Medium brown", "Deep brown"], "hair": ["Natural black", "Warm brown", "Dark plum"], "shoes": ["Charcoal", "Cream", "Brown"]}
	for part in ["skin", "hair", "shoes"]:
		var control := button("%s · %s · change" % [labels[part], choices[part][int(Game.wardrobe.state[part])]], func() -> void:
			Game.wardrobe.customize(part, (int(Game.wardrobe.state[part]) + 1) % 3)
			wardrobe(part))
		control.name = "Wardrobe_" + part
		if part == focus_part:
			first_button = control
			call_deferred("_focus_first")

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
	frame("Credits", "PH NIGHT · A fictional Lagos neighbourhood life sim.")
	line("ONE STREET. A FRESH START.")
	line("Meet your neighbours, earn a living, and make a place for yourself on the mainland.")
	line("ART & WORLD")
	line("AI-generated pixel art brings the characters, street props and startup illustration to life. Animation, UI, dialogue and synthesised audio were created for this project.")
	line("BUILT WITH GODOT")
	line("Godot Engine is available under the MIT licence. Engine and third-party dependency notices are included with Windows releases.")
	line("Thank you for playing.")

func title_screen() -> void:
	_hide_dialogue()
	Game.open_modal()
	overlay.hide()
	if is_instance_valid(title_page):
		remove_child(title_page)
		title_page.queue_free()
	title_page = preload("res://scripts/ui/TitleScreen.gd").new()
	add_child(title_page)
	var has_save: bool = Game.save.read_state(Game.save.path) != null or Game.save.read_state(Game.save.path + ".bak") != null
	title_page.setup(self, has_save)

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

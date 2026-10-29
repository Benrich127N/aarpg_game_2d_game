extends CanvasLayer

var cash_label: Label
var time_label: Label
var location_label: Label
var bars: Dictionary = {}
var prompt: Label
var toast: Label
var toast_timer: Timer
var pause_overlay: ColorRect
var settings_label: Label
var resume_button: Button
var pause_notice: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("hud")
	_build_ui()
	Global.stats_changed.connect(_update_stats)
	TimeManager.time_changed.connect(_update_time)
	Game.scenes.location_changed.connect(_update_location)
	Game.housing.changed.connect(_update_location)
	Game.settings.changed.connect(_apply_accessibility)
	_apply_accessibility()
	_update_location()
	_update_stats()
	_update_time()
	notify("Welcome home. Use E near the bed or street door. I: bag · J: quests · P: contacts · C: career · K: save")

func _build_ui() -> void:
	var root: Control = $MainUI
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 20)
	root.add_child(margin)
	var panel := PanelContainer.new()
	margin.add_child(panel)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("182a24")
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	cash_label = Label.new()
	cash_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(cash_label)
	location_label = Label.new()
	location_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(location_label)
	time_label = Label.new()
	top.add_child(time_label)
	var needs := HBoxContainer.new()
	needs.add_theme_constant_override("separation", 16)
	column.add_child(needs)
	for stat in ["Energy", "Hunger", "Health"]:
		var item := VBoxContainer.new()
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		needs.add_child(item)
		var title := Label.new()
		title.text = stat
		item.add_child(title)
		var bar := ProgressBar.new()
		bar.custom_minimum_size.y = 20
		var fill := StyleBoxFlat.new()
		fill.bg_color = {"Energy": Color("7dad86"), "Hunger": Color("d6b45f"), "Health": Color("cb8179")}[stat]
		bar.add_theme_stylebox_override("fill", fill)
		item.add_child(bar)
		bars[stat] = bar
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt.offset_top = -58
	prompt.offset_bottom = -22
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.text = "WASD / arrows · move   E · interact   Tab · phone   Esc · pause"
	root.add_child(prompt)
	toast = Label.new()
	toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	toast.offset_top = -110
	toast.offset_bottom = -70
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(toast)
	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 5.0
	toast_timer.timeout.connect(func() -> void: toast.hide())
	add_child(toast_timer)
	pause_overlay = ColorRect.new()
	pause_overlay.color = Color(0.02, 0.04, 0.03, 0.92)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(pause_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(center)
	var menu := VBoxContainer.new()
	menu.custom_minimum_size.x = 320
	menu.add_theme_constant_override("separation", 16)
	center.add_child(menu)
	var title := Label.new()
	title.text = "LAGOS LIFE · PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu.add_child(title)
	pause_notice = Label.new()
	pause_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu.add_child(pause_notice)
	resume_button = Button.new()
	resume_button.text = "Resume"
	resume_button.pressed.connect(func() -> void: set_paused(false))
	menu.add_child(resume_button)
	var settings := Button.new()
	settings.text = "Settings"
	settings.pressed.connect(func() -> void: Game.ui.settings_menu())
	menu.add_child(settings)
	settings_label = Label.new()
	settings_label.text = "Settings placeholder\nAudio and control options are coming later."
	settings_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_label.hide()
	menu.add_child(settings_label)
	var save_button := Button.new()
	save_button.text = "Save game"
	save_button.pressed.connect(func() -> void:
		if is_instance_valid(Game.ui): Game.ui.manual_save())
	menu.add_child(save_button)
	var load_button := Button.new()
	load_button.text = "Load saved game"
	load_button.pressed.connect(func() -> void:
		set_paused(false)
		if is_instance_valid(Game.ui): Game.ui.manual_load())
	menu.add_child(load_button)
	var fresh_button := Button.new()
	fresh_button.text = "New game"
	fresh_button.pressed.connect(func() -> void:
		set_paused(false)
		if is_instance_valid(Game.ui): Game.ui.new_game_prompt())
	menu.add_child(fresh_button)
	var credits_button := Button.new()
	credits_button.text = "Credits"
	credits_button.pressed.connect(func() -> void: Game.ui.credits())
	menu.add_child(credits_button)
	var title_button := Button.new()
	title_button.text = "Save and return to title"
	title_button.pressed.connect(func() -> void:
		if Game.save.write_save():
			set_paused(false)
			get_tree().change_scene_to_file("res://Scenes/ui/MainMenu.tscn")
		else: notify(Game.save.last_error))
	menu.add_child(title_button)
	pause_overlay.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not Game.modal_open:
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()

func set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_overlay.visible = value
	if value:
		pause_notice.text = ""
		resume_button.grab_focus()
	else:
		resume_button.release_focus()
		settings_label.hide()

func set_interaction_prompt(text: String) -> void:
	prompt.text = text

func notify(message: String) -> void:
	if get_tree().paused and is_instance_valid(pause_notice): pause_notice.text = message
	toast.text = message
	toast.show()
	toast_timer.start()

func _update_stats() -> void:
	cash_label.text = "₦" + format_cash(Global.cash)
	bars["Energy"].value = Global.energy
	bars["Hunger"].value = Global.hunger
	bars["Health"].value = Global.health

func _update_time() -> void:
	time_label.text = "Day %d  ·  %s" % [TimeManager.current_day, TimeManager.get_time_string()]

func format_cash(amount: int) -> String:
	var digits: String = str(amount)
	var result: String = ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			result += ","
		result += digits[index]
	return result

func _update_location() -> void:
	if not is_instance_valid(location_label): return
	location_label.text = str(Game.housing.catalog[Game.housing.current].title) if Game.scenes.location == "room" else str(Game.scenes.DESTINATIONS[Game.scenes.location].title)

func _apply_accessibility() -> void:
	var theme := Theme.new()
	theme.default_font_size = int(16 * float(Game.settings.values.text_scale))
	$MainUI.theme = theme

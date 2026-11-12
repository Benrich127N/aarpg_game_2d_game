extends CanvasLayer

var cash_label: Label
var time_label: Label
var location_label: Label
var bars: Dictionary = {}
const NEED_METER = preload("res://UI/NeedMeter.gd")
var meters: Dictionary = {}
var dialogue_active := false
const PIXEL_THEME = preload("res://scripts/ui/PixelMenuTheme.gd")
const HINT_BUTTON = preload("res://UI/ControlHintButton.gd")
var control_dock: CenterContainer
var control_buttons: Dictionary = {}
var prompt_frame: PanelContainer
var prompt: Label
var toast: Label
var toast_timer: Timer
var pause_overlay: ColorRect
var pause_menu: Control
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
		margin.add_theme_constant_override("margin_" + edge, 12)
	root.add_child(margin)
	var panel := PanelContainer.new()
	margin.add_child(panel)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("182a24")
	panel_style.border_color = Color("7b7955")
	panel_style.set_border_width_all(2)
	panel_style.shadow_color = Color(0, 0, 0, 0.3)
	panel_style.shadow_size = 3
	panel_style.shadow_offset = Vector2(0, 3)
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
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
	needs.add_theme_constant_override("separation", 10)
	column.add_child(needs)
	for stat in ["Health", "Hunger", "Energy"]:
		var item := NEED_METER.new()
		item.setup(stat)
		needs.add_child(item)
		meters[stat] = item
		bars[stat] = item.bar
	control_dock = CenterContainer.new()
	control_dock.name = "PixelControls"
	control_dock.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	control_dock.offset_top = -62
	control_dock.offset_bottom = -12
	control_dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(control_dock)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control_dock.add_child(controls)
	for entry in [["interact", "E", "Interact"], ["bag", "I", "Bag"], ["phone", "Tab", "Phone"], ["menu", "Esc", "Menu"]]:
		var button := HINT_BUTTON.new()
		button.setup(entry[0], entry[1], entry[2])
		button.tooltip_text = entry[2] + " · " + entry[1]
		button.pressed.connect(func() -> void: _activate_control(entry[0]))
		controls.add_child(button)
		control_buttons[entry[0]] = button
	control_buttons.interact.set_available(false)
	var prompt_center := CenterContainer.new()
	prompt_center.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt_center.offset_top = -106
	prompt_center.offset_bottom = -66
	prompt_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(prompt_center)
	prompt_frame = PanelContainer.new()
	prompt_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_frame.add_theme_stylebox_override("panel", PIXEL_THEME.box(Color("182d25"), Color("ad9f6b"), 8))
	prompt_center.add_child(prompt_frame)
	prompt = Label.new()
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_frame.add_child(prompt)
	prompt_frame.hide()
	toast = Label.new()
	toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	toast.offset_top = -154
	toast.offset_bottom = -112
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
	pause_menu = preload("res://scripts/ui/PauseMenu.gd").new()
	pause_overlay.add_child(pause_menu)
	pause_menu.setup(self)
	resume_button = pause_menu.buttons.Resume
	pause_notice = pause_menu.notice
	pause_overlay.hide()

func _activate_control(action: String) -> void:
	if Global.input_blocked or Game.modal_open or get_tree().paused: return
	Game.audio.sfx("click")
	match action:
		"interact":
			if not is_instance_valid(Game.player): return
			var detector: Area2D = Game.player.get_node("InteractionArea")
			var target: Area2D = detector.choose(detector.get_overlapping_areas())
			if is_instance_valid(target): target.interact()
		"bag": Game.ui.perform("bag", "")
		"phone": Game.ui.perform("phone", "")
		"menu": set_paused(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not Game.modal_open:
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()

func set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_overlay.visible = value
	control_dock.visible = not value and not dialogue_active
	prompt.visible = not value and not dialogue_active
	if value:
		pause_notice.text = ""
		pause_menu.refresh()
	else:
		resume_button.release_focus()

func set_interaction_prompt(text: String) -> void:
	prompt.text = text
	prompt_frame.visible = not text.is_empty()
	control_buttons.interact.set_available(not text.is_empty())
	prompt.visible = not dialogue_active

func set_dialogue_active(active: bool) -> void:
	dialogue_active = active
	prompt.visible = not active
	control_dock.visible = not active and not get_tree().paused
	toast.visible = not active and toast_timer.time_left > 0

func notify(message: String) -> void:
	if get_tree().paused and is_instance_valid(pause_notice): pause_notice.text = message
	toast.text = message
	toast.visible = not dialogue_active
	toast_timer.start()

func _update_stats() -> void:
	cash_label.text = "₦" + format_cash(Global.cash)
	var reduced_motion: bool = Game.settings.values.reduced_motion
	meters["Energy"].update_value(Global.energy, reduced_motion)
	meters["Hunger"].update_value(Global.hunger, reduced_motion)
	meters["Health"].update_value(Global.health, reduced_motion)

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
	var theme := PIXEL_THEME.make(float(Game.settings.values.text_scale))
	theme.default_font_size = int(16 * float(Game.settings.values.text_scale))
	$MainUI.theme = theme
	for meter in meters.values(): meter.apply_scale(float(Game.settings.values.text_scale))
	for button in control_buttons.values(): button.apply_scale(float(Game.settings.values.text_scale))
	if is_instance_valid(pause_menu): pause_menu.apply_scale(float(Game.settings.values.text_scale))
	_update_stats()

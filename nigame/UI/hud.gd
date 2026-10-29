extends CanvasLayer

var cash_label: Label
var time_label: Label
var bars: Dictionary = {}
var prompt: Label
var toast: Label
var toast_timer: Timer
var pause_overlay: ColorRect
var settings_label: Label
var resume_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	Global.stats_changed.connect(_update_stats)
	TimeManager.time_changed.connect(_update_time)
	_update_stats()
	_update_time()
	notify("Welcome. Explore the practice street with WASD or arrow keys.")

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
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	cash_label = Label.new()
	cash_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(cash_label)
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
		item.add_child(bar)
		bars[stat] = bar
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt.offset_top = -58
	prompt.offset_bottom = -22
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.text = "WASD / arrows: move   ·   E: interact   ·   Esc: pause"
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
	resume_button = Button.new()
	resume_button.text = "Resume"
	resume_button.pressed.connect(func() -> void: set_paused(false))
	menu.add_child(resume_button)
	var settings := Button.new()
	settings.text = "Settings"
	settings.pressed.connect(func() -> void: settings_label.visible = not settings_label.visible)
	menu.add_child(settings)
	settings_label = Label.new()
	settings_label.text = "Settings placeholder\nAudio and control options are coming later."
	settings_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_label.hide()
	menu.add_child(settings_label)
	pause_overlay.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()

func set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_overlay.visible = value
	if value:
		resume_button.grab_focus()
	else:
		resume_button.release_focus()
		settings_label.hide()

func set_interaction_prompt(text: String) -> void:
	prompt.text = text

func notify(message: String) -> void:
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

extends Node
const PIXEL = preload("res://scripts/ui/PixelMenuTheme.gd")
const GLYPH = preload("res://UI/ControlGlyph.gd")
var selected_tab := "audio"

func show_panel(tab: String = "") -> void:
	if tab in ["audio", "display", "controls"]: selected_tab = tab
	var ui: Node = Game.ui
	ui.frame("Settings", "Make yourself at home. Your preferences save automatically.")
	var tabs := HBoxContainer.new()
	tabs.name = "SettingsTabs"
	tabs.add_theme_constant_override("separation", 8)
	ui.body.add_child(tabs)
	for entry in [["audio", "Audio", "music"], ["display", "Display", "display"], ["controls", "Controls", "controls"]]:
		var button := Button.new()
		button.name = entry[0].capitalize() + "Tab"
		button.text = entry[1]
		button.icon = GLYPH.texture(entry[2], Color("17271f") if selected_tab == entry[0] else Color("e5cf96"))
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 46
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if selected_tab == entry[0]: selected_style(button)
		button.pressed.connect(func() -> void:
			Game.audio.sfx("click")
			show_panel(entry[0])
			focus_named(entry[0].capitalize() + "Tab"))
		tabs.add_child(button)
	match selected_tab:
		"audio": audio_page(ui)
		"display": display_page(ui)
		"controls": controls_page(ui)

func selected_style(button: Button) -> void:
	for state in ["normal", "hover", "pressed"]:
		button.add_theme_stylebox_override(state, PIXEL.box(Color("d7bb7b"), Color("f5e0ac"), 10))
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		button.add_theme_color_override(state, Color("17271f"))

func card(parent: Node) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", PIXEL.box(Color("213a2c"), Color("526a49"), 12))
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)
	return column

func text(parent: Node, content: String, muted: bool = false) -> Label:
	var label := Label.new()
	label.text = content
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if muted:
		label.add_theme_color_override("font_color", Color("b8c8ad"))
		label.add_theme_font_size_override("font_size", roundi(14 * float(Game.settings.values.text_scale)))
	parent.add_child(label)
	return label

func audio_page(ui: Node) -> void:
	for entry in [["Music", "music"], ["Ambience", "ambience"], ["SFX", "effects"]]:
		var bus: String = entry[0]
		var column := card(ui.body)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		column.add_child(row)
		var icon := GLYPH.new()
		icon.kind = entry[1]
		row.add_child(icon)
		var title := text(row, "Sound effects" if bus == "SFX" else bus)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var amount := text(row, "%d%%" % roundi(float(Game.settings.values[bus]) * 100))
		amount.name = bus + "Value"
		amount.autowrap_mode = TextServer.AUTOWRAP_OFF
		amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amount.custom_minimum_size.x = roundi(60 * float(Game.settings.values.text_scale))
		amount.add_theme_color_override("font_color", Color("e4c78c"))
		var slider := HSlider.new()
		slider.name = bus + "Volume"
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = Game.settings.values[bus]
		slider.custom_minimum_size.y = 28
		slider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		slider.tooltip_text = bus + " volume · left/right to adjust"
		slider.value_changed.connect(func(value: float) -> void:
			amount.text = "%d%%" % roundi(value * 100)
			Game.settings.set_value(bus, value))
		column.add_child(slider)
	var preview: Button = ui.button("Preview footsteps", func() -> void: Game.audio.sfx("step"))
	preview.name = "PreviewFootsteps"
	text(ui.body, "Use the sliders to find a comfortable balance.", true)

func display_page(ui: Node) -> void:
	setting_row(ui.body, "Text size", "Keep menus and dialogue comfortable to read.", "text_scale",
		[["100%", 1.0], ["120%", 1.2], ["140%", 1.4]], "display")
	setting_row(ui.body, "Reduced motion", "Keep idle poses and decorative motion still.", "reduced_motion",
		[["Off", false], ["On", true]], "display")
	setting_row(ui.body, "Fullscreen", "Choose how PH NIGHT fills your screen.", "fullscreen",
		[["Off", false], ["On", true]], "display")

func setting_row(parent: Node, title: String, description: String, key: String, values: Array, tab: String) -> void:
	var column := card(parent)
	text(column, title)
	text(column, description, true)
	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 8)
	column.add_child(choices)
	for option in values:
		var button := Button.new()
		button.name = key + "_" + str(option[0]).replace("%", "")
		button.text = option[0]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 40
		var selected: bool = Game.settings.values[key] == option[1]
		if selected:
			selected_style(button)
			button.icon = PIXEL.selector(true)
		else: PIXEL.decorate(button)
		button.pressed.connect(func() -> void:
			var focus_name := key + "_" + str(option[0]).replace("%", "")
			Game.audio.sfx("click")
			Game.settings.set_value(key, option[1])
			show_panel(tab)
			focus_named(focus_name))
		choices.add_child(button)

func controls_page(ui: Node) -> void:
	var grid := GridContainer.new()
	grid.name = "KeyboardBindings"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	ui.body.add_child(grid)
	for entry in [["WASD", "Move"], ["E", "Interact"], ["I", "Bag"], ["Tab", "Phone"], ["O", "Wardrobe"], ["J", "Journal"], ["P", "Contacts"], ["C", "Career"], ["K", "Save"], ["Esc", "Back / menu"]]:
		var column := card(grid)
		column.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		column.add_child(row)
		var keycap := PanelContainer.new()
		keycap.add_theme_stylebox_override("panel", PIXEL.box(Color("d7bb7b"), Color("f5e0ac"), 6))
		row.add_child(keycap)
		var key_label := text(keycap, entry[0])
		key_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		key_label.add_theme_color_override("font_color", Color("17271f"))
		var action_label := text(row, entry[1])
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text(ui.body, "Controller: left stick / D-pad moves · A confirms · B goes back · X opens bag · Y opens phone.", true)
	text(ui.body, "Menus support mouse, arrow keys and Enter.", true)

func focus_named(name: String) -> void:
	call_deferred("_focus_named", name)

func _focus_named(name: String) -> void:
	if not is_instance_valid(Game.ui) or not Game.ui.overlay.visible: return
	var control: Control = Game.ui.body.find_child(name, true, false)
	if control != null: control.grab_focus()

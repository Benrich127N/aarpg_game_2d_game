extends Control
const BACKDROP = preload("res://scripts/ui/MenuBackdrop.gd")
var buttons: Dictionary = {}
var first_button: Button
var ui: Node
var title: Label
var description: Label
var eyebrow: Label
var note: Label

func setup(owner_ui: Node, has_save: bool) -> void:
	ui = owner_ui
	name = "TitleScreen"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := BACKDROP.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var scroll := ScrollContainer.new()
	scroll.anchor_right = 0.38
	scroll.anchor_bottom = 1.0
	scroll.offset_left = 42
	scroll.offset_top = 56
	scroll.offset_right = -30
	scroll.offset_bottom = -34
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	scroll.add_child(column)
	eyebrow = label("WELCOME TO THE MAINLAND", Color("d9b96f"))
	column.add_child(eyebrow)
	title = label("PH NIGHT", Color("fff0cc"))
	column.add_child(title)
	var rule := ColorRect.new()
	rule.color = Color("d9b96f")
	rule.custom_minimum_size = Vector2(50, 3)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.add_child(rule)
	description = label("One street. A fresh start.\nBuild your day, one choice at a time.", Color("b8c6b4"))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 12
	column.add_child(spacer)
	add_button(column, "Continue", func() -> void: ui.start_game(false), has_save, not has_save)
	add_button(column, "New game", func() -> void:
		ui.frame("Start fresh?", "Your previous save stays on disk until the next manual save or autosave.")
		ui.button("Start new game", func() -> void: ui.start_game(true)), not has_save)
	add_button(column, "Settings", ui.settings_menu)
	add_button(column, "Credits", ui.credits)
	add_button(column, "Quit", func() -> void: get_tree().quit())
	note = label("Continue your saved story." if has_save else "Your story starts here. No saved game yet.", Color("a9b8a4"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(note)
	var caption := VBoxContainer.new()
	caption.anchor_left = 0.43
	caption.anchor_right = 0.96
	caption.offset_top = 45
	caption.add_theme_constant_override("separation", 7)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)
	var place := label("MAINLAND  /  LAGOS", Color("d9b96f"))
	place.add_theme_font_size_override("font_size", 14)
	caption.add_child(place)
	var story := label("Make a living.\nMake a life.", Color("fff0cc"))
	story.add_theme_font_size_override("font_size", 29)
	caption.add_child(story)
	var footer := label("WASD / ARROWS · MOVE     E · INTERACT", Color("b8c6b4"))
	footer.anchor_left = 0.43
	footer.anchor_top = 1.0
	footer.anchor_right = 0.97
	footer.anchor_bottom = 1.0
	footer.offset_top = -43
	footer.add_theme_font_size_override("font_size", 12)
	add_child(footer)
	apply_scale(float(Game.settings.values.text_scale))
	call_deferred("focus_default")

func label(text: String, color: Color) -> Label:
	var result := Label.new()
	result.text = text
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_theme_color_override("font_color", color)
	return result

func style(background: Color, edge: Color) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = background
	result.border_color = edge
	result.set_border_width_all(2)
	result.content_margin_left = 18
	result.content_margin_right = 18
	result.content_margin_top = 10
	result.content_margin_bottom = 10
	return result

func add_button(column: VBoxContainer, text: String, action: Callable, primary: bool = false, disabled: bool = false) -> void:
	var button := Button.new()
	button.text = text
	button.name = text.replace(" ", "")
	button.custom_minimum_size.y = 48
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.disabled = disabled
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", style(Color("d9b96f") if primary else Color("21382f"), Color("eacf8c") if primary else Color("48604c")))
	button.add_theme_stylebox_override("hover", style(Color("ecd092") if primary else Color("344f3d"), Color("eacf8c")))
	button.add_theme_stylebox_override("pressed", style(Color("b99a54") if primary else Color("172b23"), Color("eacf8c")))
	button.add_theme_stylebox_override("disabled", style(Color("182b23"), Color("2c4032")))
	var focus := style(Color.TRANSPARENT, Color("fff0cc"))
	focus.set_border_width_all(3)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color", Color("17271f") if primary else Color("f1e6c9"))
	button.add_theme_color_override("font_hover_color", Color("17271f") if primary else Color("fff0cc"))
	button.add_theme_color_override("font_pressed_color", Color("17271f") if primary else Color("fff0cc"))
	button.add_theme_color_override("font_focus_color", Color("17271f") if primary else Color("fff0cc"))
	button.add_theme_color_override("font_disabled_color", Color("7e8c79"))
	button.pressed.connect(func() -> void: Game.audio.sfx("click"))
	button.pressed.connect(action)
	column.add_child(button)
	preload("res://scripts/ui/PixelMenuTheme.gd").decorate(button)
	buttons[text] = button
	if primary: first_button = button

func apply_scale(text_scale: float) -> void:
	title.add_theme_font_size_override("font_size", roundi(48 * text_scale))
	eyebrow.add_theme_font_size_override("font_size", roundi(12 * text_scale))
	description.add_theme_font_size_override("font_size", roundi(17 * text_scale))
	note.add_theme_font_size_override("font_size", roundi(12 * text_scale))
	for button in buttons.values(): button.add_theme_font_size_override("font_size", roundi(18 * text_scale))

func focus_default() -> void:
	if visible and is_instance_valid(first_button): first_button.grab_focus()

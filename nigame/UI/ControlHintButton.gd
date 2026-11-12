extends Button
const PIXEL = preload("res://scripts/ui/PixelMenuTheme.gd")
const GLYPH = preload("res://UI/ControlGlyph.gd")
var keycap: Label
var caption: Label
var glyph: Control
var row: HBoxContainer

func setup(action: String, shortcut: String, label: String) -> void:
	name = action.capitalize() + "Hint"
	text = label
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size.y = 42
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]:
		add_theme_color_override(state, Color.TRANSPARENT)
	add_theme_stylebox_override("normal", raised(Color("203c2d"), Color("7e8b60")))
	add_theme_stylebox_override("hover", raised(Color("365238"), Color("e6cf96")))
	add_theme_stylebox_override("pressed", PIXEL.box(Color("10271c"), Color("e6cf96"), 10))
	add_theme_stylebox_override("disabled", raised(Color("1a2d24"), Color("40543c")))
	row = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	add_child(row)
	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", PIXEL.box(Color("d7be7e"), Color("f4e3b2"), 5))
	row.add_child(badge)
	keycap = Label.new()
	keycap.text = shortcut
	keycap.add_theme_color_override("font_color", Color("18291f"))
	keycap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keycap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(keycap)
	glyph = GLYPH.new()
	glyph.kind = action
	row.add_child(glyph)
	caption = Label.new()
	caption.text = label
	caption.add_theme_color_override("font_color", Color("f4e8c8"))
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(caption)
	resized.connect(_layout)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	apply_scale(1.0)

func raised(background: Color, edge: Color) -> StyleBoxFlat:
	var style := PIXEL.box(background, edge, 10)
	style.border_width_bottom = 4
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_offset = Vector2(0, 3)
	style.shadow_size = 2
	return style

func apply_scale(text_scale: float) -> void:
	caption.add_theme_font_size_override("font_size", roundi(14 * text_scale))
	keycap.add_theme_font_size_override("font_size", roundi(12 * text_scale))
	var minimum := row.get_combined_minimum_size()
	custom_minimum_size = Vector2(minimum.x + 20, maxf(42, minimum.y + 10))
	_layout()

func set_available(available: bool) -> void:
	disabled = not available
	glyph.color = Color("e6cf96") if available else Color("76866b")
	caption.add_theme_color_override("font_color", Color("f4e8c8") if available else Color("8c9b82"))
	glyph.queue_redraw()

func _layout() -> void:
	if row == null: return
	row.size = row.get_combined_minimum_size()
	row.position = (size - row.size) * 0.5

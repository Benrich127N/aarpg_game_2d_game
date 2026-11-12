extends RefCounted
static var selectors: Dictionary = {}

static func selector(active: bool) -> Texture2D:
	if selectors.has(active): return selectors[active]
	var image := Image.create(20, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	if active:
		for row in range(7):
			var width := mini(row + 1, 7 - row) * 2
			image.fill_rect(Rect2i(4, 1 + row * 2, width, 2), Color("f4db9a"))
	else:
		image.fill_rect(Rect2i(6, 6, 4, 4), Color("8a9b76"))
	selectors[active] = ImageTexture.create_from_image(image)
	return selectors[active]

static func decorate(button: Button) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_constant_override("h_separation", 12)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var update := func() -> void:
		button.icon = selector(not button.disabled and (button.has_focus() or button.is_hovered()))
	button.focus_entered.connect(update)
	button.focus_exited.connect(update)
	button.mouse_entered.connect(update)
	button.mouse_exited.connect(update)
	update.call()

static func box(background: Color, edge: Color, padding: int = 12) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = background
	result.border_color = edge
	result.set_border_width_all(2)
	result.content_margin_left = padding
	result.content_margin_right = padding
	result.content_margin_top = padding
	result.content_margin_bottom = padding
	return result

static func make(text_scale: float) -> Theme:
	var result := Theme.new()
	result.default_font_size = roundi(18 * text_scale)
	result.set_color("font_color", "Label", Color("efe6cd"))
	result.set_stylebox("normal", "Button", box(Color("263f31"), Color("637656")))
	result.set_stylebox("hover", "Button", box(Color("3b563c"), Color("e4c78c")))
	result.set_stylebox("pressed", "Button", box(Color("14291f"), Color("e4c78c")))
	result.set_stylebox("disabled", "Button", box(Color("1c3026"), Color("354c38")))
	var focus := box(Color(1, 0.88, 0.6, 0.07), Color("fff0cc"))
	focus.set_border_width_all(3)
	result.set_stylebox("focus", "Button", focus)
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		result.set_color(state, "Button", Color("fff0cc"))
	result.set_color("font_disabled_color", "Button", Color("82927d"))
	var track := box(Color("10261d"), Color("465d43"), 0)
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	result.set_stylebox("slider", "HSlider", track)
	result.set_stylebox("grabber_area", "HSlider", box(Color("bca05d"), Color("bca05d"), 0))
	result.set_stylebox("grabber_area_highlight", "HSlider", box(Color("e5c783"), Color("e5c783"), 0))
	result.set_stylebox("focus", "HSlider", box(Color.TRANSPARENT, Color("fff0cc"), 0))
	var image := Image.create(16, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color("14291f"))
	image.fill_rect(Rect2i(2, 2, 12, 20), Color("f5dfa6"))
	image.fill_rect(Rect2i(4, 4, 8, 16), Color("bca05d"))
	image.fill_rect(Rect2i(6, 8, 2, 8), Color("f5dfa6"))
	var grabber := ImageTexture.create_from_image(image)
	for state in ["grabber", "grabber_highlight", "grabber_disabled"]:
		result.set_icon(state, "HSlider", grabber)
	result.set_constant("grabber_offset", "HSlider", 0)
	result.set_stylebox("scroll", "VScrollBar", box(Color("132a20"), Color("132a20"), 3))
	result.set_stylebox("grabber", "VScrollBar", box(Color("74815d"), Color("74815d"), 3))
	result.set_stylebox("grabber_highlight", "VScrollBar", box(Color("d6bb78"), Color("d6bb78"), 3))
	result.set_stylebox("grabber_pressed", "VScrollBar", box(Color("ead7a2"), Color("ead7a2"), 3))
	return result

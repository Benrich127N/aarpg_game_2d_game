extends Control
const ART = preload("res://scripts/characters/CharacterArt.gd")
var panel: PanelContainer
var speaker: Label
var role: Label
var passage: Label
var portrait: TextureRect
var responses: HBoxContainer
var hint: Label
var pages: Array[String] = []
var page := 0
var choices: Array = []
var choice_page := 0
var owner_ui: Node
var npc_id := ""
var full_text := ""
var response_buttons: Array[Button] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel = PanelContainer.new()
	panel.name = "Card"
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 72
	panel.offset_right = -72
	panel.offset_top = -218
	panel.offset_bottom = -20
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var frame := box(Color("182d25"), Color("ead7a2"))
	frame.shadow_size = 5
	frame.shadow_offset = Vector2(0, 3)
	frame.shadow_color = Color(0, 0, 0, 0.4)
	panel.add_theme_stylebox_override("panel", frame)
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	column.add_child(row)
	var portrait_frame := PanelContainer.new()
	portrait_frame.add_theme_stylebox_override("panel", box(Color("31483a"), Color("6d7854")))
	row.add_child(portrait_frame)
	portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(64, 76)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait_frame.add_child(portrait)
	var text_column := VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 6)
	row.add_child(text_column)
	var header := HBoxContainer.new()
	text_column.add_child(header)
	speaker = Label.new()
	speaker.add_theme_color_override("font_color", Color("f7df9f"))
	header.add_child(speaker)
	role = Label.new()
	role.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	role.add_theme_color_override("font_color", Color("b6c6b0"))
	header.add_child(role)
	var close_button := Button.new()
	close_button.text = "Close · Esc"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.flat = true
	close_button.pressed.connect(func() -> void: owner_ui.close())
	header.add_child(close_button)
	passage = Label.new()
	passage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	passage.custom_minimum_size.y = 58
	passage.add_theme_color_override("font_color", Color("f6eddb"))
	text_column.add_child(passage)
	responses = HBoxContainer.new()
	responses.add_theme_constant_override("separation", 10)
	column.add_child(responses)
	hint = Label.new()
	hint.add_theme_color_override("font_color", Color("b6c6b0"))
	column.add_child(hint)
	hide()

func box(background: Color, edge: Color) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = background
	result.border_color = edge
	result.set_border_width_all(2)
	result.content_margin_left = 14
	result.content_margin_right = 14
	result.content_margin_top = 10
	result.content_margin_bottom = 10
	return result

func open(ui: Node, id: String, text: String, options: Array) -> void:
	owner_ui = ui
	npc_id = id
	full_text = text
	choices = options
	page = 0
	choice_page = 0
	speaker.text = str(Game.dialogue.data[id].name)
	role.text = "  ·  " + str(Game.dialogue.data[id].role)
	var head := AtlasTexture.new()
	head.atlas = ART.frames(id).get_frame_texture("idle_down", 0)
	head.region = Rect2(4, 0, 24, 27)
	portrait.texture = head
	apply_scale(float(Game.settings.values.text_scale))
	show()
	show_page()

func paginate(text: String, limit: int) -> Array[String]:
	var result: Array[String] = []
	var chunk := ""
	for word in text.split(" ", false):
		if not chunk.is_empty() and chunk.length() + word.length() + 1 > limit:
			result.append(chunk)
			chunk = ""
		chunk += (" " if not chunk.is_empty() else "") + word
	if not chunk.is_empty(): result.append(chunk)
	if result.is_empty(): result.append("")
	return result

func apply_scale(text_scale: float) -> void:
	var theme := Theme.new()
	theme.default_font_size = roundi(16 * text_scale)
	panel.theme = theme
	speaker.add_theme_font_size_override("font_size", roundi(19 * text_scale))
	role.add_theme_font_size_override("font_size", roundi(13 * text_scale))
	hint.add_theme_font_size_override("font_size", roundi(12 * text_scale))
	pages = paginate(full_text, 170 if text_scale < 1.2 else 115)
	page = mini(page, pages.size() - 1)
	if visible: show_page()

func show_page() -> void:
	passage.text = pages[page]
	for child in responses.get_children():
		responses.remove_child(child)
		child.queue_free()
	response_buttons.clear()
	if page < pages.size() - 1:
		add_response("Continue", advance)
		hint.text = "E / Enter / A · next     Esc / B · close     %d / %d" % [page + 1, pages.size()]
	else:
		# More than three choices use two choices plus a More/Previous button.
		var per_page := 2 if choices.size() > 3 else 3
		for index in range(choice_page * per_page, mini((choice_page + 1) * per_page, choices.size())):
			add_response(choices[index].text, choices[index].action)
		if choices.size() > 3:
			var more := (choice_page + 1) * per_page < choices.size()
			add_response("More options →" if more else "← Previous options", func() -> void:
				choice_page = choice_page + 1 if more else 0
				show_page())
		if choices.is_empty(): add_response("Goodbye", owner_ui.close)
		hint.text = "← → · choose     E / Enter / A · confirm     Esc / B · close"
	call_deferred("focus_first")

func add_response(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 42
	button.add_theme_stylebox_override("normal", box(Color("2c4635"), Color("6d805a")))
	button.add_theme_stylebox_override("hover", box(Color("415c40"), Color("ead7a2")))
	button.add_theme_stylebox_override("pressed", box(Color("14271e"), Color("ead7a2")))
	button.add_theme_stylebox_override("focus", box(Color.TRANSPARENT, Color("f4e4b8")))
	button.add_theme_color_override("font_color", Color("f6eddb"))
	button.pressed.connect(func() -> void: Game.audio.sfx("click"))
	button.pressed.connect(action)
	responses.add_child(button)
	response_buttons.append(button)

func focus_first() -> void:
	if visible and not response_buttons.is_empty(): response_buttons[0].grab_focus()

func advance() -> void:
	if page < pages.size() - 1:
		page += 1
		show_page()
	else:
		var focused := get_viewport().gui_get_focus_owner()
		if focused in response_buttons: focused.pressed.emit()
		elif not response_buttons.is_empty(): response_buttons[0].pressed.emit()

func handle_input(event: InputEvent) -> bool:
	if event.is_echo(): return false
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		advance()
		return true
	return false

func show_notice(text: String) -> void:
	full_text = text
	page = 0
	apply_scale(float(Game.settings.values.text_scale))

extends Control
const PIXEL = preload("res://scripts/ui/PixelMenuTheme.gd")
var hud: Node
var art: Control
var panel: PanelContainer
var scroll: ScrollContainer
var title: Label
var context: Label
var notice: Label
var footer: Label
var buttons: Dictionary = {}

func setup(owner_hud: Node) -> void:
	hud = owner_hud
	name = "PixelPauseMenu"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var rail := ColorRect.new()
	rail.color = Color("13251f")
	rail.anchor_right = 0.34
	rail.anchor_bottom = 1.0
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rail)
	art = preload("res://scripts/ui/MenuPageArt.gd").new()
	art.anchor_right = 0.31
	art.anchor_bottom = 1.0
	art.offset_left = 44
	art.offset_right = -12
	art.offset_top = 54
	art.offset_bottom = -48
	add_child(art)
	art.present("Pause")
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for entry in [["left", 440], ["right", 36], ["top", 36], ["bottom", 36]]:
		margin.add_theme_constant_override("margin_" + entry[0], entry[1])
	add_child(margin)
	panel = PanelContainer.new()
	var frame := PIXEL.box(Color("182d25"), Color("b7a571"), 24)
	frame.shadow_size = 4
	frame.shadow_offset = Vector2(0, 4)
	frame.shadow_color = Color(0, 0, 0, 0.4)
	panel.add_theme_stylebox_override("panel", frame)
	margin.add_child(panel)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	panel.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 14)
	scroll.add_child(column)
	var eyebrow := Label.new()
	eyebrow.text = "PH NIGHT  /  TAKE A MOMENT"
	eyebrow.add_theme_color_override("font_color", Color("d9b96f"))
	column.add_child(eyebrow)
	title = Label.new()
	title.text = "Paused"
	title.add_theme_color_override("font_color", Color("fff0cc"))
	column.add_child(title)
	context = Label.new()
	context.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	context.add_theme_color_override("font_color", Color("b9c8af"))
	column.add_child(context)
	var rule := ColorRect.new()
	rule.color = Color("817b51")
	rule.custom_minimum_size.y = 2
	column.add_child(rule)
	var resume := action(column, "Resume", func() -> void: hud.set_paused(false))
	for state in ["normal", "hover", "pressed"]:
		resume.add_theme_stylebox_override(state, PIXEL.box(Color("d9b96f"), Color("f2dda4")))
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		resume.add_theme_color_override(state, Color("17271f"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	column.add_child(grid)
	action(grid, "Settings", func() -> void: Game.ui.settings_menu())
	action(grid, "Credits", func() -> void: Game.ui.credits())
	action(grid, "Save game", func() -> void: Game.ui.manual_save())
	action(grid, "Load saved game", func() -> void:
		hud.set_paused(false)
		Game.ui.manual_load())
	action(grid, "New game", func() -> void:
		hud.set_paused(false)
		Game.ui.new_game_prompt())
	action(grid, "Save & return to title", func() -> void:
		if Game.save.write_save():
			hud.set_paused(false)
			get_tree().change_scene_to_file("res://Scenes/ui/MainMenu.tscn")
		else: hud.notify(Game.save.last_error))
	notice = Label.new()
	notice.name = "PauseNotice"
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_color_override("font_color", Color("e7c580"))
	column.add_child(notice)
	footer = Label.new()
	footer.text = "Esc / B · resume     Arrows · select     Enter / A · confirm"
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_theme_color_override("font_color", Color("acbda5"))
	column.add_child(footer)
	apply_scale(float(Game.settings.values.text_scale))

func action(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.name = text.replace(" ", "").replace("&", "And")
	button.custom_minimum_size.y = 52
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(func() -> void: Game.audio.sfx("click"))
	button.pressed.connect(callback)
	parent.add_child(button)
	PIXEL.decorate(button)
	buttons[text] = button
	return button

func apply_scale(text_scale: float) -> void:
	theme = PIXEL.make(text_scale)
	title.add_theme_font_size_override("font_size", roundi(34 * text_scale))
	context.add_theme_font_size_override("font_size", roundi(15 * text_scale))
	footer.add_theme_font_size_override("font_size", roundi(13 * text_scale))
	art.apply_scale(text_scale)

func refresh() -> void:
	context.text = "Day %d · %s\n%s · ₦%s" % [TimeManager.current_day, TimeManager.get_time_string(), hud.location_label.text, hud.format_cash(Global.cash)]
	scroll.scroll_vertical = 0
	buttons.Resume.grab_focus()

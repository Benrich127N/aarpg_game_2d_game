extends Control
## A readable landmark schematic, independent of world coordinates.
const PLACES := [
	["room", "Your room", "Sleep · wardrobe", Vector2(0.17, 0.22)],
	["food", "Amara's food", "Meals · provisions", Vector2(0.5, 0.22)],
	["provisions", "Sade's shop", "Buy · stock work", Vector2(0.83, 0.22)],
	["courtyard", "Courtyard", "Bisi · garden · rest", Vector2(0.17, 0.78)],
	["cafe", "Outdoor tables", "Eat · rest", Vector2(0.5, 0.78)],
	["club", "PH Night Club", "Nneka · work · music", Vector2(0.83, 0.78)],
]
var cards: Array[PanelContainer] = []

func _ready() -> void:
	name = "NeighborhoodMap"
	custom_minimum_size.y = 320 * float(Game.settings.values.text_scale)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for place in PLACES:
		var panel := PanelContainer.new()
		var active: bool = Game.scenes.location == place[0]
		panel.add_theme_stylebox_override("panel", preload("res://scripts/ui/PixelMenuTheme.gd").box(Color("344f3d") if active else Color("21382f"), Color("f5dfa6") if active else Color("637656"), 10))
		var column := VBoxContainer.new()
		panel.add_child(column)
		for text in [("● " if active else "") + place[1], place[2]]:
			var label := Label.new()
			label.text = text
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", roundi(16 * float(Game.settings.values.text_scale)))
			column.add_child(label)
		add_child(panel)
		cards.append(panel)
	resized.connect(_layout)
	call_deferred("_layout")

func _layout() -> void:
	for index in range(cards.size()):
		var width := (size.x - 64) / 3.0
		cards[index].size = Vector2(width, 76 * float(Game.settings.values.text_scale))
		cards[index].position = size * PLACES[index][3] - cards[index].size * 0.5
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2(24, size.y * 0.5), Vector2(size.x - 24, size.y * 0.5), Color("b49a70"), 8)
	for x in [0.17, 0.5, 0.83]:
		draw_line(Vector2(size.x * x, size.y * 0.22), Vector2(size.x * x, size.y * 0.78), Color("b49a70"), 4)
	if Game.scenes.location == "mainland":
		draw_circle(Vector2(size.x * 0.5, size.y * 0.5), 10, Color("f5dfa6"))

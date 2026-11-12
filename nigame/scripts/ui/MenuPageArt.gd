extends Control
const PROPS = preload("res://scripts/world/PixelArt.gd")
const PEOPLE = preload("res://scripts/characters/CharacterArt.gd")
var eyebrow: Label
var headline: Label
var caption: Label
var illustration: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	eyebrow = text_label("", Color("d9b96f"))
	headline = text_label("", Color("fff0cc"))
	caption = text_label("", Color("b8c6b4"))
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	illustration = Node2D.new()
	add_child(illustration)
	resized.connect(_layout)

func text_label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label

func present(page: String) -> void:
	for child in illustration.get_children():
		illustration.remove_child(child)
		child.queue_free()
	if page == "Pause":
		eyebrow.text = "TAKE A BREATHER"
		headline.text = "The street\ncan wait."
		caption.text = "Take your time. Your day will be right here when you return."
		prop("desk", Vector2(-65, -40), 150)
		prop("chair", Vector2(35, 35), 150)
		prop("plant", Vector2(120, 45), 74)
	elif page == "Settings":
		eyebrow.text = "AUDIO & COMFORT"
		headline.text = "Make it\nyour own."
		caption.text = "Find your rhythm. Adjust the sound, text and motion to suit your day."
		prop("desk", Vector2(-15, 10), 220)
		prop("plant", Vector2(105, 25), 78)
		prop("generator", Vector2(-110, 45), 70)
	elif page == "Credits":
		eyebrow.text = "MADE FOR THE MAINLAND"
		headline.text = "The people.\nThe place."
		caption.text = "A small street with stories to tell. Thank you for spending time here."
		prop("food", Vector2(0, -40), 220)
		for entry in [["tunde", -80], ["amara", 0], ["bisi", 80]]:
			var character := Sprite2D.new()
			character.texture = PEOPLE.frames(entry[0]).get_frame_texture("idle_down", 0)
			character.position = Vector2(entry[1], 70)
			character.scale = Vector2(2.5, 2.5)
			character.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			illustration.add_child(character)
	else:
		eyebrow.text = "A FRESH START"
		headline.text = "Another\nfirst day."
		caption.text = "A room of your own. A neighbourhood to explore. Make tomorrow yours."
		prop("bed", Vector2(-20, 15), 200)
		prop("plant", Vector2(90, 30), 80)
		prop("parcel", Vector2(-105, 48), 70)
	apply_scale(float(Game.settings.values.text_scale))

func prop(id: String, at: Vector2, width: float) -> void:
	var anchor := Node2D.new()
	anchor.position = at
	anchor.add_child(PROPS.sprite(id, width))
	illustration.add_child(anchor)

func apply_scale(text_scale: float) -> void:
	eyebrow.add_theme_font_size_override("font_size", roundi(12 * text_scale))
	headline.add_theme_font_size_override("font_size", roundi(30 * text_scale))
	caption.add_theme_font_size_override("font_size", roundi(16 * text_scale))
	_layout()

func _layout() -> void:
	if not is_instance_valid(headline): return
	eyebrow.position = Vector2.ZERO
	headline.position = Vector2(0, 34)
	caption.position = Vector2(0, 42 + headline.get_minimum_size().y)
	caption.size.x = size.x
	illustration.position = Vector2(size.x * 0.5, size.y * 0.73)
	illustration.scale = Vector2.ONE * minf(size.x / 320.0, size.y / 610.0)

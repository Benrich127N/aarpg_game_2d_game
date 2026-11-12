extends Area2D
@export var title: String = "Interact"
@export var kind: String = ""
@export var action_id: String = ""
@export var interaction_priority: int = 0
@export var tint: Color = Color("e8ba63")
const PIXEL_ART = preload("res://scripts/world/PixelArt.gd")
var prop_art: Sprite2D
var caption: Label
var targeted := false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	monitoring = false
	add_to_group("interactables")
	if not has_node("CollisionShape2D"):
		var collision := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 20
		collision.shape = circle
		add_child(collision)
	var prop: String = ""
	var art_width: float = 96.0
	match kind:
		"door":
			if action_id == "room": prop = "room"
			elif action_id == "provisions": prop = "kiosk"
		"shop": prop = "food" if action_id == "food" else "kiosk"
		"clothes": prop = "clothes"
		"parcel": prop = "parcel"
		"job": prop = "stock"
		"travel": prop = "bus"
		"bed": prop = "bed"
		"housing": prop = "desk"
		"furniture": prop = "chair"
	if prop in ["room", "food", "kiosk"]: art_width = 192.0
	elif prop in ["clothes", "bus", "stock"]: art_width = 128.0
	elif prop == "parcel": art_width = 64.0
	if not prop.is_empty():
		prop_art = PIXEL_ART.sprite(prop, art_width)
		add_child(prop_art)
	var label := Label.new()
	caption = label
	label.text = title
	label.position = Vector2(-90, -60)
	if prop_art != null: label.position.y = 12.0 - art_width
	label.size = Vector2(180, 50)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Game.settings.changed.connect(_caption_scale)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)
	_caption_scale()
	set_targeted(false)
	queue_redraw()

func _caption_scale() -> void:
	if caption == null: return
	caption.add_theme_font_size_override("font_size", roundi(17 * float(Game.settings.values.text_scale)))
	caption.position.x = -180
	caption.size.x = 360

func set_targeted(value: bool) -> void:
	targeted = value
	if caption != null: caption.visible = value or kind in ["door", "travel"]

func _draw() -> void:
	if prop_art != null: return
	if kind == "npc":
		preload("res://scripts/characters/CharacterGrounding.gd").shadow(self)
	else:
		draw_rect(Rect2(-20, -20, 40, 40), tint)
		draw_rect(Rect2(-20, -20, 40, 40), Color("f1e2bd"), false, 2)

func interact() -> void:
	if Global.input_blocked or get_tree().paused or not is_instance_valid(Game.ui): return
	Game.ui.perform(kind, action_id)

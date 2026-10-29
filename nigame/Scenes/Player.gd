extends CharacterBody2D
const ART = preload("res://scripts/characters/LayeredCharacter.gd")
@export var speed: float = 240.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var facing: String = "down"
var layers: Array[AnimatedSprite2D] = []
var step_time: float = 0.0

func _ready() -> void:
	layers.append(sprite)
	for part in ["Clothing", "Hair", "Shoes"]:
		var layer := AnimatedSprite2D.new()
		layer.name = part
		add_child(layer)
		layers.append(layer)
	Game.wardrobe.changed.connect(update_outfit)
	update_outfit()
	Game.settings.changed.connect(_settings_changed)
	_settings_changed()

func _settings_changed() -> void:
	$Camera2D.position_smoothing_enabled = not bool(Game.settings.values.reduced_motion)

func update_outfit() -> void:
	var outfit: Dictionary = Game.wardrobe.state
	layers[0].sprite_frames = ART.frames("body", [Color("d2a07b"), Color("a46d48"), Color("70452f")][int(outfit.skin)])
	layers[1].sprite_frames = ART.frames("shirt", Color(Game.wardrobe.CLOTHES[outfit.shirt].color))
	layers[2].sprite_frames = ART.frames("hair", [Color("242a29"), Color("4b3229"), Color("352f46")][int(outfit.hair)], int(outfit.hair))
	layers[3].sprite_frames = ART.frames("shoes", [Color("292e32"), Color("eee1c2"), Color("8a4c3d")][int(outfit.shoes)])
	for layer in layers:
		layer.position = Vector2(0, 2)
		layer.play("idle_" + facing)

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Global.input_blocked: direction = Vector2.ZERO
	velocity = direction * speed
	move_and_slide()
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = "side"
		else:
			facing = "up" if direction.y < 0 else "down"
		step_time += delta
		if step_time >= 0.32 and get_position_delta().length() > 0.1:
			step_time = 0
			Game.audio.sfx("step")
	else: step_time = 0
	for layer in layers:
		layer.flip_h = facing == "side" and direction.x < 0 if direction != Vector2.ZERO else layer.flip_h
		layer.play(("walk_" if direction != Vector2.ZERO else "idle_") + facing)
		if layer != sprite:
			layer.frame = sprite.frame
			layer.frame_progress = sprite.frame_progress

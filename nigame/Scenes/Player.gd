extends CharacterBody2D

@export var speed: float = 240.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var facing: String = "down"

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Global.input_blocked:
		direction = Vector2.ZERO
	velocity = direction * speed
	move_and_slide()
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = "side"
			sprite.flip_h = direction.x < 0
		else:
			facing = "up" if direction.y < 0 else "down"
			sprite.flip_h = false
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)

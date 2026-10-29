extends CharacterBody2D

const SPEED = 200.0

func _physics_process(delta):
	# Get input
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()
	
	# Flip sprite based on direction
	if direction.x != 0:
		$Sprite2D.flip_h = direction.x < 0

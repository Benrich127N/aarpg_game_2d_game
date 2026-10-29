extends CharacterBody2D

const SPEED = 300.0
@onready var anim_player = $AnimationPlayer

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction:
		velocity = direction * SPEED
		anim_player.play("walk") # Start the walk loop
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		anim_player.stop() # Or play an "idle" animation
		
	move_and_slide()
	
	# Flip sprite based on direction
	if direction.x != 0:
		$Sprite2D.flip_h = direction.x < 0

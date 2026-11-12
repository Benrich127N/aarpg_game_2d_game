extends "res://scripts/world/Interactable.gd"
var agent: NavigationAgent2D
var destination: Vector2
const CHARACTER_ART = preload("res://scripts/characters/CharacterArt.gd")
var sprite: AnimatedSprite2D
var facing: String = "down"

func _ready() -> void:
	kind = "npc"
	interaction_priority = 10
	if Game.events.state.positions.has(action_id):
		var saved: Array = Game.events.state.positions[action_id]
		position = Vector2(float(saved[0]), float(saved[1]))
	else: position = Game.events.target(action_id)
	super._ready()
	sprite = AnimatedSprite2D.new()
	sprite.name = "CharacterSprite"
	sprite.sprite_frames = CHARACTER_ART.frames(action_id)
	sprite.position = preload("res://scripts/characters/CharacterGrounding.gd").VISUAL_ORIGIN
	sprite.scale = Vector2(2, 2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	sprite.play("idle_down")
	for child in get_children():
		if child is Label: child.position.y = -94
	agent = NavigationAgent2D.new()
	agent.path_desired_distance = 4
	agent.target_desired_distance = 4
	add_child(agent)
	TimeManager.time_changed.connect(_schedule)
	_schedule()

func _schedule() -> void:
	destination = Game.events.target(action_id)
	agent.target_position = destination

func _physics_process(delta: float) -> void:
	if Global.input_blocked:
		_update_animation(Vector2.ZERO, false)
		return
	var previous := position
	var walking := false
	if not is_instance_valid(Game.player) or global_position.distance_to(Game.player.global_position) > 900:
		position = destination
	elif NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) > 0:
		if not agent.is_navigation_finished():
			position = position.move_toward(agent.get_next_path_position(), 55 * delta)
			walking = position.distance_to(previous) > 0.01
	_update_animation(position - previous, walking)
	Game.events.state.positions[action_id] = [position.x, position.y]

func _update_animation(movement: Vector2, walking: bool) -> void:
	if walking:
		facing = "side" if absf(movement.x) > absf(movement.y) else ("up" if movement.y < 0 else "down")
		if facing == "side": sprite.flip_h = movement.x < 0
	if facing != "side": sprite.flip_h = false
	sprite.play(("walk_" if walking else "idle_") + facing)

extends "res://scripts/world/Interactable.gd"
var agent: NavigationAgent2D
var destination: Vector2

func _ready() -> void:
	kind = "npc"
	interaction_priority = 10
	if Game.events.state.positions.has(action_id):
		var saved: Array = Game.events.state.positions[action_id]
		position = Vector2(float(saved[0]), float(saved[1]))
	else: position = Game.events.target(action_id)
	super._ready()
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
	if Global.input_blocked: return
	if not is_instance_valid(Game.player) or global_position.distance_to(Game.player.global_position) > 900:
		position = destination
	elif NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) > 0:
		if not agent.is_navigation_finished():
			position = position.move_toward(agent.get_next_path_position(), 55 * delta)
	Game.events.state.positions[action_id] = [position.x, position.y]

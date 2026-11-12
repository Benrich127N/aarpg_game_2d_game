extends Area2D
var target: Area2D
var marker: Node2D

func _ready() -> void:
	marker = preload("res://scripts/world/TargetMarker.gd").new()
	add_child(marker)

func choose(candidates: Array) -> Area2D:
	var best: Area2D = null
	for candidate in candidates:
		if not is_instance_valid(candidate) or not candidate.has_method("interact"): continue
		if best == null:
			best = candidate
			continue
		var interaction_priority_a: int = candidate.interaction_priority
		var interaction_priority_b: int = best.interaction_priority
		var distance_a: float = global_position.distance_squared_to(candidate.global_position)
		var distance_b: float = global_position.distance_squared_to(best.global_position)
		if interaction_priority_a > interaction_priority_b or (interaction_priority_a == interaction_priority_b and (distance_a < distance_b or (is_equal_approx(distance_a, distance_b) and str(candidate.get_path()) < str(best.get_path())))):
			best = candidate
	return best

func _physics_process(_delta: float) -> void:
	var previous := target
	if Global.input_blocked:
		target = null
	else:
		target = choose(get_overlapping_areas())
	if previous != target:
		if is_instance_valid(previous): previous.set_targeted(false)
		if is_instance_valid(target): target.set_targeted(true)
	marker.visible = is_instance_valid(target) and not Game.modal_open and not get_tree().paused
	if marker.visible: marker.global_position = target.global_position + Vector2(0, 16)
	if is_instance_valid(Game.ui):
		Game.ui.set_prompt(("Talk to " if target.kind in ["npc", "venue_person"] else "") + target.title if is_instance_valid(target) else "")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not Global.input_blocked and not get_tree().paused:
		target = choose(get_overlapping_areas())
		if is_instance_valid(target):
			target.interact()
			get_viewport().set_input_as_handled()

extends Resource
@export var npc_id: String = ""
@export var work: Vector2 = Vector2.ZERO
@export var lunch: Vector2 = Vector2.ZERO
@export var home: Vector2 = Vector2.ZERO

func destination(hour: int) -> Vector2:
	if hour < 6 or hour >= 20: return home
	if hour >= 12 and hour < 14: return lunch
	return work

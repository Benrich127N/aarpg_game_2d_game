extends Node2D
var district: Node2D
var settle_frames: int = 0

func _ready() -> void:
	Game.player = $Player
	Game.scenes.location_changed.connect(rebuild_world)
	Game.housing.changed.connect(_refresh_home)
	if not Game.booted:
		Game.booted = true
		if Game.auto_load: Game.save.load_save()
	if district == null: rebuild_world()

func rebuild_world() -> void:
	var load_start: int = Time.get_ticks_usec()
	var old_position: Vector2 = $Player.position
	var previous: String = str(district.get("district_id")) if is_instance_valid(district) else ""
	if is_instance_valid(district):
		remove_child(district)
		district.queue_free()
	var scene: PackedScene = load(Game.scenes.DESTINATIONS[Game.scenes.location].path)
	district = scene.instantiate()
	add_child(district)
	move_child(district, 0)
	if Game.scenes.pending_position.x >= 0:
		$Player.position = Game.scenes.pending_position
		Game.scenes.pending_position = Vector2(-1, -1)
	elif previous == Game.scenes.location:
		$Player.position = old_position
	else:
		$Player.position = district.get_node(Game.scenes.spawn).position
	$Player/Camera2D.reset_smoothing()
	settle_frames = 2
	Game.scene_load_ms.append(float(Time.get_ticks_usec() - load_start) / 1000.0)
	if Game.scene_load_ms.size() > 100: Game.scene_load_ms.pop_front()

func _refresh_home() -> void:
	if Game.scenes.location == "room" and is_instance_valid(district):
		rebuild_world()

func _physics_process(_delta: float) -> void:
	if settle_frames <= 0: return
	settle_frames -= 1
	if settle_frames > 0 or not is_instance_valid(district): return
	var collision: CollisionShape2D = $Player/CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision.shape
	query.transform = collision.global_transform
	query.collision_mask = 1
	query.exclude = [$Player.get_rid()]
	if not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
		$Player.position = district.get_node("PlayerSpawn").position
		$Player/Camera2D.reset_smoothing()

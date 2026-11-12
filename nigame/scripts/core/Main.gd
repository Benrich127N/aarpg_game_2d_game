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
	# Recover saves made after walking beyond an interior's visible footprint.
	var bounds: Rect2 = district.player_bounds()
	if not bounds.has_point($Player.position):
		$Player.position = district.get_node("PlayerSpawn").position
	var camera: Camera2D = $Player/Camera2D
	# Leave room for the character's head and the HUD at every street edge.
	camera.limit_left = -96
	camera.limit_top = -160
	camera.limit_right = 2016
	camera.limit_bottom = 1248
	if Game.scenes.location == "room":
		camera.top_level = true
		camera.zoom = Vector2(1.125, 1.125)
		camera.global_position = district.get_node("RoomInterior").camera_center()
	elif Game.scenes.location in ["club", "courtyard", "provisions"]:
		camera.top_level = true
		camera.zoom = Vector2.ONE
		camera.global_position = Vector2(640, 380)
	else:
		camera.top_level = false
		camera.position = Vector2.ZERO
		camera.zoom = Vector2.ONE
	camera.reset_smoothing()
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

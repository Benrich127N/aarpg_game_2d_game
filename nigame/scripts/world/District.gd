extends Node2D
@export var district_id: String = "mainland"
const INTERACTABLE = preload("res://scripts/world/Interactable.gd")
const NPC_SCENE = preload("res://Scenes/npc/NPC.tscn")
var ground: TileMapLayer
var obstacles: TileMapLayer
var tint: CanvasModulate

func _ready() -> void:
	_build_tiles()
	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = Vector2(448, 448) if district_id == "room" else Vector2(1550, 520)
	add_child(spawn)
	var door_spawn := Marker2D.new()
	door_spawn.name = "DoorSpawn"
	door_spawn.position = Vector2(320, 416)
	add_child(door_spawn)
	if district_id == "room": _room()
	elif district_id == "mainland": _mainland()
	else: _district()
	tint = CanvasModulate.new()
	add_child(tint)
	TimeManager.time_changed.connect(_update_tint)
	_update_tint()
	if district_id == "mainland": _navigation()
	if district_id != "room":
		var effects: Node2D = load("res://scripts/world/StreetEffects.gd").new()
		effects.name = "StreetEffects"
		add_child(effects)

func _build_tiles() -> void:
	var image := Image.create(128, 32, false, Image.FORMAT_RGBA8)
	var palette: Array[Color] = [Color("60795a"), Color("a28d6b"), Color("4d6261"), Color("3b443e")]
	if district_id == "room": palette = [Color("b8956d"), Color("a78865"), Color("654f43"), Color("463c37")]
	elif district_id == "business": palette[0] = Color("6d8285")
	elif district_id == "lekki": palette[0] = Color("769579")
	elif district_id == "island": palette[0] = Color("849f99")
	for index in range(4):
		image.fill_rect(Rect2i(index * 32, 0, 32, 32), palette[index])
		image.fill_rect(Rect2i(index * 32, 30, 32, 2), palette[index].darkened(0.08))
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(image)
	atlas.texture_region_size = Vector2i(32, 32)
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(32, 32)
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.add_source(atlas, 0)
	for index in range(4):
		atlas.create_tile(Vector2i(index, 0))
		if index == 3:
			var tile: TileData = atlas.get_tile_data(Vector2i(index, 0), 0)
			tile.set_collision_polygons_count(0, 1)
			tile.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)]))
	ground = TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = tile_set
	add_child(ground)
	var road := TileMapLayer.new()
	road.name = "Roads"
	road.tile_set = tile_set
	add_child(road)
	obstacles = TileMapLayer.new()
	obstacles.name = "Obstacles"
	obstacles.tile_set = tile_set
	add_child(obstacles)
	for x in range(60):
		for y in range(34):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			if y in range(15, 19) and district_id != "room": road.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
			elif y % 4 == 0: ground.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))
			if x == 0 or y == 0 or x == 59 or y == 33: obstacles.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))

func block(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y): obstacles.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))

func object(label: String, kind: String, id: String, position_at: Vector2, color: Color = Color("e8ba63")) -> Area2D:
	var item: Area2D = INTERACTABLE.new()
	item.title = label
	item.kind = kind
	item.action_id = id
	item.position = position_at
	item.tint = color
	add_child(item)
	return item

func sign_text(text: String, at: Vector2, width: float = 600) -> void:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size.x = width
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color("fff0cc"))
	add_child(label)

func _mainland() -> void:
	block(Rect2i(7, 7, 6, 3))
	block(Rect2i(18, 7, 5, 3))
	block(Rect2i(28, 7, 5, 3))
	object("Your room", "door", "room", Vector2(320, 336))
	object("Amara's food", "shop", "food", Vector2(640, 336), Color("ce7751"))
	object("Sade's provisions", "shop", "kiosk", Vector2(960, 336), Color("7bb3a7"))
	object("Clothing stall", "clothes", "", Vector2(800, 688), Color("a99ad0"))
	object("Collect parcel", "parcel", "", Vector2(640, 688))
	object("Stock shift", "job", "stock", Vector2(1440, 768))
	object("Bus stop", "travel", "", Vector2(1632, 432), Color("e3bd45"))
	var positions: Array[Vector2] = [Vector2(480, 688), Vector2(640, 416), Vector2(960, 416), Vector2(1280, 416), Vector2(1440, 688)]
	var colors: Array[Color] = [Color("e3b95d"), Color("c97057"), Color("83b6a0"), Color("a99ad0"), Color("6da5c0")]
	for index in range(5):
		var id: String = Game.relationships.NPC_IDS[index]
		var npc: Area2D = NPC_SCENE.instantiate()
		npc.title = Game.dialogue.data[id].name
		npc.action_id = id
		npc.position = positions[index]
		npc.tint = colors[index]
		add_child(npc)

func _room() -> void:
	var right: int = 27 if Game.housing.current == "apartment" else 21
	for rect in [Rect2i(5, 6, right - 4, 1), Rect2i(5, 6, 1, 12), Rect2i(right, 6, 1, 12), Rect2i(5, 17, 8, 1), Rect2i(15, 17, right - 14, 1)]: block(rect)
	if Game.housing.current == "apartment":
		block(Rect2i(21, 7, 1, 6))
		sign_text("Courtyard nook", Vector2(704, 256), 250)
	object("Bed · sleep", "bed", "", Vector2(288, 288), Color("8da9ca"))
	object("Street door", "door", "mainland", Vector2(448, 520))
	object("Housing desk", "housing", "", Vector2(608, 288))
	object("Furniture", "furniture", "", Vector2(608, 448), Color("ab7857"))
	for entry in Game.housing.furniture:
		var chair := Polygon2D.new()
		chair.position = Vector2(int(entry.x) * 32 + 16, int(entry.y) * 32 + 16)
		chair.polygon = PackedVector2Array([Vector2(-10, -12), Vector2(10, -12), Vector2(10, 10), Vector2(-10, 10)])
		chair.color = Color("70472d")
		add_child(chair)
func _district() -> void:
	block(Rect2i(8, 9, 12, 4))
	block(Rect2i(24, 9, 12, 4))
	object("Bus stop · return", "travel", "", Vector2(1536, 448))
	object("Provisions", "shop", "kiosk", Vector2(800, 448))
	object("Stock shift", "job", "stock", Vector2(1120, 448))

func _update_tint() -> void:
	var hour: int = TimeManager.current_hour
	tint.color = Color("8492b0") if (hour >= 19 or hour < 6) and district_id != "room" else Color.WHITE

func _navigation() -> void:
	var region := NavigationRegion2D.new()
	region.name = "NavigationRegion2D"
	var polygon := NavigationPolygon.new()
	polygon.vertices = PackedVector2Array([Vector2(64, 384), Vector2(1856, 384), Vector2(1856, 960), Vector2(64, 960)])
	polygon.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	region.navigation_polygon = polygon
	add_child(region)

extends Node2D
@export var district_id: String = "mainland"
const INTERACTABLE = preload("res://scripts/world/Interactable.gd")
const NPC_SCENE = preload("res://Scenes/npc/NPC.tscn")
const PIXEL_ART = preload("res://scripts/world/PixelArt.gd")
var ground: TileMapLayer
var obstacles: TileMapLayer
var tint: CanvasModulate
const COMPACT_MAPS := ["room", "club", "courtyard", "provisions"]

func player_bounds() -> Rect2:
	if district_id == "room":
		var right: int = 27 if Game.housing.current == "apartment" else 21
		return Rect2(192, 224, (right - 6) * 32, 328)
	if district_id in ["club", "courtyard", "provisions"]: return Rect2(256, 224, 768, 352)
	return Rect2(32, 32, 1856, 1024)

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
	elif district_id == "club": _club()
	elif district_id == "courtyard": _courtyard()
	elif district_id == "provisions": _provisions()
	elif district_id == "mainland": _mainland()
	else: _district()
	tint = CanvasModulate.new()
	add_child(tint)
	TimeManager.time_changed.connect(_update_tint)
	_update_tint()
	if district_id == "mainland": _navigation()
	if district_id not in COMPACT_MAPS:
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
			if y in range(15, 19) and district_id not in COMPACT_MAPS: road.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
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
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("fff0cc"))
	label.add_theme_color_override("font_shadow_color", Color("14231e"))
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)

func _mainland() -> void:
	marker("CourtyardDoorSpawn", Vector2(320, 800))
	marker("ShopDoorSpawn", Vector2(960, 416))
	var neighborhood := preload("res://scripts/world/NeighborhoodArt.gd").new()
	neighborhood.mode = "street"
	neighborhood.name = "NeighborhoodArt"
	add_child(neighborhood)
	var gate := room_object("Community courtyard · enter", "door", "courtyard", Vector2(320, 880), 0)
	gate.hide()
	var cafe := room_object("Amara's seating · eat and meet", "place", "cafe", Vector2(736, 912), 0)
	cafe.hide()
	block(Rect2i(19, 25, 3, 2))
	block(Rect2i(25, 25, 3, 2))
	var club_spawn := Marker2D.new()
	club_spawn.name = "ClubDoorSpawn"
	club_spawn.position = Vector2(1280, 800)
	add_child(club_spawn)
	var club_door := room_object("PH Night Club · enter", "door", "club", Vector2(1280, 880), 0)
	club_door.hide()
	sign_text("COURTYARD", Vector2(236, 804), 230)
	sign_text("PH NIGHT CLUB", Vector2(1188, 804), 250)
	sign_text("AMARA'S SEATING", Vector2(600, 752), 360)
	block(Rect2i(7, 7, 6, 3))
	block(Rect2i(18, 7, 5, 3))
	block(Rect2i(28, 7, 5, 3))
	object("Your room", "door", "room", Vector2(320, 336))
	object("Amara's food", "shop", "food", Vector2(640, 336), Color("ce7751"))
	object("Sade's shop · enter", "door", "provisions", Vector2(960, 336), Color("7bb3a7"))
	object("Clothing stall", "clothes", "", Vector2(800, 688), Color("a99ad0"))
	object("Collect parcel", "parcel", "", Vector2(640, 688))
	object("Stock shift", "job", "stock", Vector2(1440, 768))
	object("Bus stop", "travel", "", Vector2(1632, 432), Color("e3bd45"))
	decoration("plant", Vector2(208, 336), 72)
	decoration("plant", Vector2(1072, 336), 72)
	decoration("generator", Vector2(1120, 688), 80)
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
	ground.hide()
	obstacles.hide()
	var interior := preload("res://scripts/world/RoomInterior.gd").new()
	interior.name = "RoomInterior"
	interior.right_wall = right
	add_child(interior)
	for rect in [Rect2i(5, 6, right - 4, 1), Rect2i(5, 6, 1, 12), Rect2i(right, 6, 1, 12), Rect2i(5, 17, 8, 1), Rect2i(15, 17, right - 14, 1)]: block(rect)
	# The doorway is activated with E; walking through it must not escape the room.
	block(Rect2i(13, 18, 2, 1))
	if Game.housing.current == "apartment":
		block(Rect2i(21, 7, 1, 6))
		decoration("plant", Vector2(748, 320), 80)
		decoration("chair", Vector2(816, 384), 80)
	room_object("Bed · sleep", "bed", "", Vector2(288, 288), 128)
	var door := room_object("Street door", "door", "mainland", Vector2(448, 520), 0)
	door.hide()
	room_object("Housing desk", "housing", "", Vector2(608, 288), 112)
	room_object("Furniture", "furniture", "", Vector2(608, 448), 88)
	for entry in Game.housing.furniture:
		decoration("chair", Vector2(int(entry.x) * 32 + 16, int(entry.y) * 32 + 16), 48)
	decoration("plant", Vector2(216, 488), 72)

func room_object(label: String, kind: String, id: String, at: Vector2, width: float) -> Area2D:
	var item := object(label, kind, id, at)
	for child in item.get_children():
		if child is Label: child.hide()
	if item.prop_art != null and width > 0:
		item.prop_art.scale = Vector2.ONE * width / item.prop_art.texture.get_width()
		item.prop_art.position.y = 20.0 - width * 0.5
	return item

func decoration(prop: String, at: Vector2, width: float) -> void:
	var anchor := Node2D.new()
	anchor.position = at
	anchor.add_child(PIXEL_ART.sprite(prop, width))
	add_child(anchor)

func _district() -> void:
	var landmark := preload("res://scripts/world/DistrictLandmarks.gd").new()
	landmark.name = "DistrictLandmark"
	landmark.district_id = district_id
	add_child(landmark)
	block(Rect2i(8, 9, 12, 4))
	block(Rect2i(24, 9, 12, 4))
	var names := {"business": "MARINA EXCHANGE", "lekki": "PALM COURT", "island": "WATERFRONT WALK"}
	sign_text(names.get(district_id, "NEIGHBORHOOD"), Vector2(292, 172), 540)
	object("Bus stop · return", "travel", "", Vector2(1536, 448))
	object("Provisions", "shop", "kiosk", Vector2(800, 448))
	object("Stock shift", "job", "stock", Vector2(1120, 448))

func _update_tint() -> void:
	var hour: int = TimeManager.current_hour
	tint.color = Color("8492b0") if (hour >= 19 or hour < 6) and district_id not in ["room", "club", "provisions"] else Color.WHITE

func _draw() -> void:
	if district_id not in COMPACT_MAPS:
		draw_rect(Rect2(-4096, -4096, 10000, 10000), Color("24382f"))

func _club() -> void:
	ground.hide()
	obstacles.hide()
	var interior := preload("res://scripts/world/ClubInterior.gd").new()
	interior.name = "ClubInterior"
	add_child(interior)
	get_node("PlayerSpawn").position = Vector2(640, 536)
	for rect in [Rect2i(7, 6, 26, 1), Rect2i(7, 6, 1, 13), Rect2i(32, 6, 1, 13), Rect2i(7, 18, 26, 1), Rect2i(10, 8, 9, 2), Rect2i(25, 8, 5, 3)]: block(rect)
	var exit := room_object("Street door · leave club", "door", "mainland", Vector2(640, 552), 0)
	exit.hide()
	var shift := room_object("Bar shift · work for cash", "job", "club", Vector2(464, 368), 0)
	shift.hide()
	sign_text("PH NIGHT  /  CLUB", Vector2(400, 196), 480)
	sign_text("BAR", Vector2(400, 272), 180)
	person("Nneka · shift supervisor", "nneka", "sade", Vector2(656, 320))
	person("Kemi · guest", "kemi", "bisi", Vector2(416, 448))
	person("Dele · DJ", "dele", "femi", Vector2(864, 376))
	var dance := room_object("Dance floor", "place", "dance", Vector2(704, 448), 0)
	dance.hide()

func marker(label: String, at: Vector2) -> void:
	var point := Marker2D.new()
	point.name = label
	point.position = at
	add_child(point)

func person(label: String, id: String, art: String, at: Vector2, established: bool = false) -> void:
	var actor := preload("res://scripts/world/VenuePerson.gd").new()
	actor.title = label
	actor.action_id = id
	actor.art_id = art
	actor.kind = "npc" if established else "venue_person"
	actor.position = at
	add_child(actor)

func _venue(mode: String) -> void:
	ground.hide()
	obstacles.hide()
	var art := preload("res://scripts/world/NeighborhoodArt.gd").new()
	art.mode = mode
	art.name = "NeighborhoodArt"
	add_child(art)
	get_node("PlayerSpawn").position = Vector2(640, 536)
	for rect in [Rect2i(7, 6, 26, 1), Rect2i(7, 6, 1, 13), Rect2i(32, 6, 1, 13), Rect2i(7, 18, 26, 1)]: block(rect)
	var exit := room_object("Street gate" if mode == "courtyard" else "Street door", "door", "mainland", Vector2(640, 552), 0)
	exit.hide()
	sign_text("COMMUNITY COURTYARD" if mode == "courtyard" else "SADE'S PROVISIONS / STOCKROOM", Vector2(352 if mode == "courtyard" else 288, 190), 720)

func _courtyard() -> void:
	_venue("courtyard")
	for rect in [Rect2i(10, 9, 5, 2), Rect2i(25, 9, 5, 2), Rect2i(10, 14, 3, 1), Rect2i(27, 14, 3, 1), Rect2i(19, 7, 2, 2)]: block(rect)
	person("Bisi", "bisi", "bisi", Vector2(720, 400), true)
	var garden := room_object("Garden plan · inspect", "place", "garden", Vector2(640, 304), 0)
	garden.hide()
	var bench := room_object("Courtyard bench", "place", "bench", Vector2(448, 480), 0)
	bench.hide()

func _provisions() -> void:
	_venue("provisions")
	for rect in [Rect2i(9, 8, 6, 2), Rect2i(17, 8, 6, 2), Rect2i(25, 8, 6, 2), Rect2i(9, 13, 5, 2), Rect2i(25, 13, 3, 2)]: block(rect)
	person("Sade", "sade", "sade", Vector2(368, 368), true)
	person("Femi", "femi", "femi", Vector2(864, 368), true)
	var till := room_object("Provisions counter · buy", "shop", "kiosk", Vector2(368, 512), 0)
	till.hide()
	var shift := room_object("Stockroom · work a shift", "job", "stock", Vector2(864, 512), 0)
	shift.hide()
	sign_text("PROVISIONS", Vector2(292, 430), 240)
	sign_text("STOCKROOM", Vector2(788, 238), 250)

func _navigation() -> void:
	var region := NavigationRegion2D.new()
	region.name = "NavigationRegion2D"
	var polygon := NavigationPolygon.new()
	polygon.vertices = PackedVector2Array([Vector2(64, 384), Vector2(1856, 384), Vector2(1856, 960), Vector2(64, 960)])
	polygon.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	region.navigation_polygon = polygon
	add_child(region)

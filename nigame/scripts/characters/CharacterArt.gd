extends RefCounted
## Converts generated four-column, three-row sheets to aligned 32x48 game frames.
const SHEETS := {
	"player": preload("res://assets/art/characters/player-v1.png"),
	"tunde": preload("res://assets/art/characters/tunde-v1.png"),
	"amara": preload("res://assets/art/characters/amara-v1.png"),
	"sade": preload("res://assets/art/characters/sade-v1.png"),
	"bisi": preload("res://assets/art/characters/bisi-v1.png"),
	"femi": preload("res://assets/art/characters/femi-v1.png"),
}
static var images: Dictionary = {}
static var animations: Dictionary = {}
static var player_walk_cells: Array[Image] = []
static var npc_walk_cells: Dictionary = {}
const NPC_HEAD_HEIGHT := {"tunde": 20, "amara": 24, "sade": 22, "bisi": 25, "femi": 21}

static func npc_cells(id: String) -> Array[Image]:
	if npc_walk_cells.has(id): return npc_walk_cells[id]
	var source := cells(id)
	var result: Array[Image] = []
	var height: int = NPC_HEAD_HEIGHT[id]
	for row in range(3):
		var reference := source[row * 4]
		if row != 1:
			# Select an existing face whose eyes survived nearest-neighbour sampling.
			var best := eye_score(reference, height, row == 0)
			for step in range(1, 4):
				var score := eye_score(source[row * 4 + step], height, row == 0)
				if score > best:
					reference = source[row * 4 + step]
					best = score
		for step in range(4):
			var frame := align_head(source[row * 4 + step], reference)
			# Rig a single head over the moving body instead of independently
			# resampling eye/pupil pixels in each generated pose.
			frame.blit_rect(reference, Rect2i(0, 0, 32, height), Vector2i.ZERO)
			result.append(frame)
	npc_walk_cells[id] = result
	return result

static func eye_score(frame: Image, height: int, paired: bool) -> float:
	var counts := Vector2.ZERO
	var heights := Vector2.ZERO
	for y in range(height):
		for x in range(32):
			var pixel := frame.get_pixel(x, y)
			if pixel.a < 0.7 or minf(pixel.r, minf(pixel.g, pixel.b)) <= 0.65 or pixel.s >= 0.25: continue
			if x < 16:
				counts.x += 1
				heights.x += y
			else:
				counts.y += 1
				heights.y += y
	if not paired: return counts.x + counts.y
	if counts.x == 0 or counts.y == 0: return -100.0
	var mismatch := absf(heights.x / counts.x - heights.y / counts.y)
	return minf(counts.x, counts.y) * 100.0 - mismatch * 10.0 - absf(counts.x - counts.y)

static func player_cells() -> Array[Image]:
	if not player_walk_cells.is_empty(): return player_walk_cells
	player_walk_cells = cells("player").duplicate()
	for row in range(2):
		var standing := player_walk_cells[row * 4]
		var contact := align_head(player_walk_cells[row * 4 + 1], standing)
		var opposite := contact.duplicate()
		opposite.flip_x()
		opposite = align_head(opposite, standing)
		# Reuse one stable passing pose and alternate the leading arm/leg.
		player_walk_cells[row * 4 + 1] = contact
		player_walk_cells[row * 4 + 2] = standing
		player_walk_cells[row * 4 + 3] = opposite
	return player_walk_cells

static func align_head(frame: Image, reference: Image) -> Image:
	var head_region := Rect2i(0, 0, 32, 18)
	var head := opaque_bounds(frame, head_region)
	var anchor := opaque_bounds(reference, head_region)
	var shift := Vector2i(roundi(anchor.get_center().x - head.get_center().x), anchor.position.y - head.position.y)
	var used := opaque_bounds(frame, Rect2i(0, 0, 32, 48))
	shift.x = clampi(shift.x, -used.position.x, 32 - used.end.x)
	shift.y = clampi(shift.y, -used.position.y, 48 - used.end.y)
	var result := Image.create(32, 48, false, Image.FORMAT_RGBA8)
	result.fill(Color.TRANSPARENT)
	result.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), shift)
	return result

static func opaque_bounds(image: Image, area: Rect2i) -> Rect2i:
	# Generated alpha fringes can contain almost invisible pixels far from the head.
	# They must not shift the character's animation anchor.
	var start := area.end
	var end := area.position
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			if image.get_pixel(x, y).a >= 0.7:
				start = start.min(Vector2i(x, y))
				end = end.max(Vector2i(x + 1, y + 1))
	return Rect2i(start, end - start)

static func cells(id: String) -> Array[Image]:
	if images.has(id): return images[id]
	var sheet: Image = SHEETS[id].get_image()
	var extracted: Array[Image] = []
	var bounds := Rect2i()
	for row in range(3):
		for column in range(4):
			var start := Vector2i(column * sheet.get_width() / 4, row * sheet.get_height() / 3)
			var end := Vector2i((column + 1) * sheet.get_width() / 4, (row + 1) * sheet.get_height() / 3)
			var cell := sheet.get_region(Rect2i(start, end - start))
			extracted.append(cell)
			var used := cell.get_used_rect()
			bounds = used if bounds.size == Vector2i.ZERO else bounds.merge(used)
	var ratio := minf(30.0 / bounds.size.x, 44.0 / bounds.size.y)
	var size := Vector2i(maxi(1, roundi(bounds.size.x * ratio)), maxi(1, roundi(bounds.size.y * ratio)))
	var result: Array[Image] = []
	for cell in extracted:
		var cropped := cell.get_region(bounds)
		cropped.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
		var frame := Image.create(32, 48, false, Image.FORMAT_RGBA8)
		frame.fill(Color.TRANSPARENT)
		frame.blit_rect(cropped, Rect2i(Vector2i.ZERO, size), Vector2i((32 - size.x) / 2, 46 - size.y))
		result.append(frame)
	images[id] = result
	return result

static func build(textures: Array[Texture2D]) -> SpriteFrames:
	var result := SpriteFrames.new()
	result.remove_animation("default")
	var directions := ["down", "up", "side"]
	for row in range(3):
		for action in ["idle", "walk"]:
			var animation: String = action + "_" + directions[row]
			result.add_animation(animation)
			result.set_animation_speed(animation, 7.0)
			result.set_animation_loop(animation, true)
			for step in range(4 if action == "walk" else 1):
				result.add_frame(animation, textures[row * 4 + step])
	return result

static func frames(id: String) -> SpriteFrames:
	if animations.has(id): return animations[id]
	var textures: Array[Texture2D] = []
	var source := npc_cells(id) if NPC_HEAD_HEIGHT.has(id) else cells(id)
	for frame in source: textures.append(ImageTexture.create_from_image(frame))
	animations[id] = build(textures)
	return animations[id]

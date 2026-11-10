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
	for frame in cells(id): textures.append(ImageTexture.create_from_image(frame))
	animations[id] = build(textures)
	return animations[id]

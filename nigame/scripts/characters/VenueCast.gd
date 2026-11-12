extends RefCounted
## Original code-native idle portraits/sprites for the stationary club cast.
const PEOPLE := {
	"nneka": {"name": "Nneka", "role": "Shift supervisor", "greeting": "Welcome to PH Night. The bar is on your left. Ask me about work whenever you need a shift."},
	"kemi": {"name": "Kemi", "role": "Club guest", "greeting": "I come here to unwind after work. You don't have to spend your whole evening behind the bar!"},
	"dele": {"name": "Dele", "role": "DJ", "greeting": "Welcome to the booth. I'm keeping the music going. There is space on the dance floor if you want to join in."},
}
static var cache: Dictionary = {}

static func frames(id: String) -> SpriteFrames:
	if cache.has(id): return cache[id]
	var image := Image.create(32, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var outline := Color("242a29")
	var skin := Color("a46d48") if id != "kemi" else Color("d2a07b")
	var shirt: Color = {"nneka": Color("d4ab54"), "kemi": Color("c76c56"), "dele": Color("696da8")}[id]
	image.fill_rect(Rect2i(10, 6, 12, 5), outline)
	image.fill_rect(Rect2i(8, 10, 16, 12), outline)
	image.fill_rect(Rect2i(10, 11, 12, 11), skin)
	image.fill_rect(Rect2i(11, 19, 10, 3), skin.darkened(0.18))
	image.fill_rect(Rect2i(12, 22, 8, 3), skin)
	for x in [11, 19]:
		image.fill_rect(Rect2i(x, 14, 3, 2), Color("eee1c2"))
		image.fill_rect(Rect2i(x + 1, 14, 1, 2), outline)
	image.fill_rect(Rect2i(14, 20, 4, 1), Color("70452f"))
	image.fill_rect(Rect2i(9, 25, 14, 12), outline)
	image.fill_rect(Rect2i(10, 25, 12, 11), shirt)
	image.fill_rect(Rect2i(10, 26, 3, 10), shirt.lightened(0.15))
	image.fill_rect(Rect2i(20, 26, 2, 10), shirt.darkened(0.22))
	for x in [6, 23]:
		image.fill_rect(Rect2i(x, 26, 3, 5), shirt)
		image.fill_rect(Rect2i(x, 31, 3, 6), skin)
	for x in [10, 18]:
		image.fill_rect(Rect2i(x, 36, 5, 8), Color("253143"))
		image.fill_rect(Rect2i(x, 43, 6, 3), outline)
		image.fill_rect(Rect2i(x, 45, 6, 1), Color("eee1c2"))
	match id:
		"nneka":
			image.fill_rect(Rect2i(13, 2, 7, 5), outline) # High bun and service apron.
			image.fill_rect(Rect2i(12, 29, 8, 8), Color("eee1c2"))
			image.fill_rect(Rect2i(11, 28, 10, 2), Color("bc955e"))
			image.fill_rect(Rect2i(15, 31, 4, 3), Color("b49a70"))
		"kemi":
			for x in [5, 20]: image.fill_rect(Rect2i(x, 5, 8, 9), outline)
			image.fill_rect(Rect2i(9, 9, 14, 3), outline)
			for at in [Vector2i(14, 27), Vector2i(17, 30), Vector2i(14, 33)]: image.fill_rect(Rect2i(at, Vector2i(2, 2)), Color("e3cf9e"))
		"dele":
			image.fill_rect(Rect2i(9, 7, 14, 4), outline)
			image.fill_rect(Rect2i(8, 8, 16, 2), Color("79b4a5"))
			for x in [7, 22]: image.fill_rect(Rect2i(x, 12, 3, 6), Color("79b4a5"))
			image.fill_rect(Rect2i(14, 26, 4, 7), Color("79b4a5"))
	var texture := ImageTexture.create_from_image(image)
	var textures: Array[Texture2D] = []
	for frame in range(12): textures.append(texture)
	cache[id] = preload("res://scripts/characters/CharacterArt.gd").build(textures)
	return cache[id]

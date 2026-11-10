extends RefCounted
## Runtime wardrobe palette layers extracted from the generated player's distinct colours.
const ART = preload("res://scripts/characters/CharacterArt.gd")
static var cache: Dictionary = {}

static func frames(part: String, color: Color, variant: int = 0) -> SpriteFrames:
	var key := "%s:%s:%d" % [part, color.to_html(), variant]
	if cache.has(key): return cache[key]
	var textures: Array[Texture2D] = []
	for source in ART.player_cells():
		var layer := Image.create(32, 48, false, Image.FORMAT_RGBA8)
		layer.fill(Color.TRANSPARENT)
		for y in range(48):
			for x in range(32):
				var pixel: Color = source.get_pixel(x, y)
				if pixel.a == 0: continue
				var category := "body"
				if pixel.h > 0.38 and pixel.h < 0.58 and pixel.s > 0.45:
					category = "shirt"
				elif y < 22 and pixel.v < 0.36 and pixel.s < 0.38:
					category = "hair"
				elif y > 34 and pixel.r > pixel.g * 1.6 and pixel.r > pixel.b * 1.4:
					category = "shoes"
				if category != part: continue
				var shade := 1.0
				if part == "shirt": shade = pixel.v / 0.78
				elif part == "hair": shade = pixel.v / 0.14
				elif part == "shoes": shade = pixel.v / 0.75
				elif pixel.h > 0.025 and pixel.h < 0.12 and pixel.s > 0.4:
					shade = pixel.v / 0.65
				else:
					layer.set_pixel(x, y, pixel)
					continue
				var tinted := Color(color.r * shade, color.g * shade, color.b * shade, pixel.a)
				layer.set_pixel(x, y, tinted)
		textures.append(ImageTexture.create_from_image(layer))
	cache[key] = ART.build(textures)
	return cache[key]

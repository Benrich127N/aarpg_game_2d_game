extends RefCounted

static func frames(part: String, color: Color, variant: int = 0) -> SpriteFrames:
	var result := SpriteFrames.new()
	result.remove_animation("default")
	for direction in ["down", "up", "side"]:
		for action in ["idle", "walk"]:
			var animation: String = action + "_" + direction
			result.add_animation(animation)
			result.set_animation_speed(animation, 7)
			result.set_animation_loop(animation, true)
			for step in range(4 if action == "walk" else 1):
				var image := Image.create(32, 48, false, Image.FORMAT_RGBA8)
				image.fill(Color.TRANSPARENT)
				var bounce: int = 1 if action == "walk" and step % 2 == 1 else 0
				var leg: int = (1 if step == 1 else -1 if step == 3 else 0) if action == "walk" else 0
				if part == "body":
					image.fill_rect(Rect2i(11, 5 + bounce, 10, 12), color)
					image.fill_rect(Rect2i(8, 19 + bounce, 4, 13), color)
					image.fill_rect(Rect2i(20, 19 + bounce, 4, 13), color)
					image.fill_rect(Rect2i(11, 30, 4, 11 + leg), Color("343b45"))
					image.fill_rect(Rect2i(17, 30, 4, 11 - leg), Color("343b45"))
					if direction != "up":
						image.fill_rect(Rect2i(17 if direction == "side" else 12, 10 + bounce, 2, 2), Color("242a29"))
						if direction == "down": image.fill_rect(Rect2i(18, 10 + bounce, 2, 2), Color("242a29"))
				elif part == "shirt":
					image.fill_rect(Rect2i(10, 18 + bounce, 12, 14), color)
					image.fill_rect(Rect2i(7, 18 + bounce, 4, 6), color.darkened(0.1))
					image.fill_rect(Rect2i(21, 18 + bounce, 4, 6), color.darkened(0.1))
					image.fill_rect(Rect2i(11, 29 + bounce, 10, 2), color.lightened(0.15))
				elif part == "hair":
					image.fill_rect(Rect2i(10, 3 + bounce, 12, 5 + variant * 2), color)
					if direction == "up": image.fill_rect(Rect2i(10, 6 + bounce, 12, 8), color)
				elif part == "shoes":
					image.fill_rect(Rect2i(10, 40 + leg, 6, 4), color)
					image.fill_rect(Rect2i(17, 40 - leg, 6, 4), color)
				result.add_frame(animation, ImageTexture.create_from_image(image))
	return result

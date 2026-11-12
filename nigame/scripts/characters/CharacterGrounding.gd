extends RefCounted
const VISUAL_ORIGIN := Vector2(0, -22)
const FOOT_Y := 22.0

static func shadow(canvas: CanvasItem) -> void:
	canvas.draw_rect(Rect2(-12, 18, 24, 6), Color(0, 0, 0, 0.18))
	canvas.draw_rect(Rect2(-16, 20, 32, 2), Color(0, 0, 0, 0.12))

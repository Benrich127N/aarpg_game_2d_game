extends Node2D
## Screen-independent gold corners identify the single selected interaction.
func _ready() -> void:
	top_level = true
	z_index = 20
	hide()

func _draw() -> void:
	for side_x in [-1, 1]:
		for side_y in [-1, 1]:
			var corner := Vector2(side_x * 26, side_y * 18)
			draw_line(corner, corner - Vector2(side_x * 9, 0), Color("f5dfa6"), 2)
			draw_line(corner, corner - Vector2(0, side_y * 7), Color("f5dfa6"), 2)

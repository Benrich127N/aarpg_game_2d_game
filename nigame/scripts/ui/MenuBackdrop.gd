extends Control
const PROPS = preload("res://scripts/world/PixelArt.gd")
const CHARACTERS = preload("res://scripts/characters/CharacterArt.gd")
var street: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	street = Node2D.new()
	add_child(street)
	for entry in [["room", Vector2(650, 470), 190.0], ["food", Vector2(850, 470), 190.0], ["kiosk", Vector2(1060, 470), 190.0], ["plant", Vector2(548, 480), 76.0], ["plant", Vector2(1170, 480), 70.0], ["bus", Vector2(1080, 604), 208.0], ["parcel", Vector2(700, 591), 58.0]]:
		var anchor := Node2D.new()
		anchor.position = entry[1]
		anchor.add_child(PROPS.sprite(entry[0], entry[2]))
		street.add_child(anchor)
	for entry in [["tunde", Vector2(760, 563)], ["amara", Vector2(850, 490)], ["sade", Vector2(970, 490)], ["bisi", Vector2(625, 535)]]:
		var character := Sprite2D.new()
		character.texture = CHARACTERS.frames(entry[0]).get_frame_texture("idle_down", 0)
		character.position = entry[1]
		character.scale = Vector2(2, 2)
		character.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		street.add_child(character)
	resized.connect(_layout)
	_layout()

func _layout() -> void:
	if street != null: street.scale = size / Vector2(1280, 720)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, size / Vector2(1280, 720))
	draw_rect(Rect2(0, 0, 1280, 720), Color("142a2c"))
	draw_rect(Rect2(470, 100, 810, 200), Color("203b3b"))
	draw_rect(Rect2(470, 222, 810, 110), Color("4d5750"))
	draw_rect(Rect2(470, 295, 810, 65), Color("927659"))
	# A square-pixel moon and a quiet, deterministic skyline.
	draw_rect(Rect2(1092, 92, 48, 40), Color("e4c58a"))
	draw_rect(Rect2(1086, 100, 60, 24), Color("e4c58a"))
	for i in range(13):
		var x := 488 + i * 65
		var height := 42 + (i * 37 % 85)
		draw_rect(Rect2(x, 345 - height, 56, height), Color("293f3b"))
		for window in range(3):
			if (i + window) % 3 != 0:
				draw_rect(Rect2(x + 9 + window * 14, 360 - height, 5, 7), Color("b39a63"))
	draw_rect(Rect2(470, 345, 810, 159), Color("7c7960"))
	draw_rect(Rect2(470, 476, 810, 8), Color("b29d70"))
	draw_rect(Rect2(470, 504, 810, 148), Color("314b46"))
	for i in range(9): draw_rect(Rect2(500 + i * 104, 566, 44, 4), Color("a7a17b"))
	draw_rect(Rect2(470, 648, 810, 72), Color("1d3630"))
	# Festoon lights use chunky pixels and stay still for reduced-motion comfort.
	for i in range(29):
		var x := 486 + i * 28
		var y := 164 + roundi(sin(float(i) / 28.0 * PI) * 30)
		draw_rect(Rect2(x, y, 30, 2), Color("152824"))
		if i % 2 == 0:
			draw_rect(Rect2(x + 11, y + 2, 2, 8), Color("152824"))
			draw_rect(Rect2(x + 8, y + 9, 8, 8), Color("efd19b"))
	# Dark menu rail with a narrow brass edge separates text from the street.
	draw_rect(Rect2(0, 0, 488, 720), Color("13251f"))
	draw_rect(Rect2(486, 0, 2, 720), Color("817952"))

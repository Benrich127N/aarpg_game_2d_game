extends Node2D

const WORLD_SIZE: Vector2 = Vector2(1920, 1080)

func _ready() -> void:
	add_wall(Vector2(960, 12), Vector2(1920, 24))
	add_wall(Vector2(960, 1068), Vector2(1920, 24))
	add_wall(Vector2(12, 540), Vector2(24, 1080))
	add_wall(Vector2(1908, 540), Vector2(24, 1080))
	add_wall(Vector2(1120, 480), Vector2(64, 320))

func add_wall(at: Vector2, size: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = at
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	collision.shape = rectangle
	wall.add_child(collision)
	var visual := Polygon2D.new()
	var half: Vector2 = size / 2.0
	visual.polygon = PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
	visual.color = Color("596455")
	wall.add_child(visual)
	add_child(wall)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("293d36"))
	for x in range(0, 1921, 64):
		draw_line(Vector2(x, 0), Vector2(x, 1080), Color("30463d"))
	for y in range(0, 1081, 64):
		draw_line(Vector2(0, y), Vector2(1920, y), Color("30463d"))
	draw_rect(Rect2(128, 420, 1600, 160), Color("46534b"))

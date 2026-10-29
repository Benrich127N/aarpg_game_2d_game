extends Node2D
var lights: Array[PointLight2D] = []
var rain: Line2D
var phase: float = 0.0

func _ready() -> void:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for x in range(64):
		for y in range(64):
			var strength: float = maxf(0, 1 - Vector2(x - 32, y - 32).length() / 32.0)
			image.set_pixel(x, y, Color(1, 0.83, 0.55, strength * strength))
	var texture: Texture2D = ImageTexture.create_from_image(image)
	for at in [Vector2(400, 480), Vector2(960, 480), Vector2(1520, 480)]:
		var post := Line2D.new()
		post.points = PackedVector2Array([at, at - Vector2(0, 65)])
		post.width = 5
		post.default_color = Color("38423d")
		add_child(post)
		var light := PointLight2D.new()
		light.position = at - Vector2(0, 55)
		light.texture = texture
		light.texture_scale = 6
		light.energy = 0.8
		add_child(light)
		lights.append(light)
	TimeManager.time_changed.connect(update)
	Game.events.changed.connect(update)
	Game.settings.changed.connect(update)
	update()

func update() -> void:
	var night: bool = TimeManager.current_hour >= 19 or TimeManager.current_hour < 6
	for light in lights: light.visible = night
	set_process(Game.events.state.weather == "rain" and not bool(Game.settings.values.reduced_motion))
	queue_redraw()

func _process(delta: float) -> void:
	phase = fmod(phase + delta * 160, 80)
	queue_redraw()

func _draw() -> void:
	if Game.events.state.weather != "rain": return
	for x in range(40, 1920, 90):
		for y in range(0, 1080, 80):
			var at: Vector2 = Vector2(x, y + phase)
			draw_line(at, at + Vector2(-5, 14), Color(0.65, 0.8, 0.9, 0.4), 1)

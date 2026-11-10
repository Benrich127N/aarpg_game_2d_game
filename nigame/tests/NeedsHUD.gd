extends Node
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/needs-hud-settings.cfg"
	Game.reset()
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	var hud: CanvasLayer = get_tree().get_first_node_in_group("hud")
	Game.settings.set_value("reduced_motion", true)
	Global.health = 20
	Global.hunger = 40
	Global.energy = 0
	Global.stats_changed.emit()
	check(hud.meters.Health.status.text.begins_with("Critical"), "Health warns at critical boundary")
	check(hud.meters.Hunger.status.text.begins_with("Hungry"), "Hunger warns at low boundary")
	check(hud.meters.Energy.status.text.begins_with("Exhausted"), "Empty energy gives rest advice")
	check(hud.bars.Energy.value == 0 and hud.bars.Hunger.value == 40, "Reduced motion updates fill immediately")
	check(hud.meters.Energy.amount.text == "0 / 100", "Empty stat retains readable numeric value")
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/review-needs-low.png")
	Global.health = 41
	Global.hunger = 100
	Global.energy = 100
	Global.stats_changed.emit()
	check(hud.meters.Health.status.text == "Healthy", "Warning clears after recovery")
	check(hud.meters.Hunger.status.text == "Well fed" and hud.bars.Hunger.value == 100, "Full hunger explicitly means well fed")
	Game.settings.set_value("reduced_motion", false)
	Global.change_energy(-50)
	await get_tree().create_timer(0.3).timeout
	check(is_equal_approx(hud.bars.Energy.value, 50), "Animated fill reaches current stat")
	Game.settings.set_value("text_scale", 1.4)
	for window_size in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1600, 900)]:
		get_window().size = window_size
		for frame in range(3): await get_tree().process_frame
		for meter in hud.meters.values():
			check(meter.amount.get_global_rect().end.x <= hud.get_node("MainUI").size.x, "Numeric values fit at maximum text scale")
			check(meter.status.size.x >= meter.status.get_minimum_size().x, "Status text fits at maximum text scale")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/review-needs-large-text.png")
	print("NEEDS HUD: PASS" if failures == 0 else "NEEDS HUD: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

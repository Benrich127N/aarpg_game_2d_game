extends Node

func capture(path: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.reset()
	TimeManager.clock_paused = true
	var main: Node2D = preload("res://scenes/main/Main.tscn").instantiate()
	add_child(main)
	await capture("res://.godot/review-room.png")
	Game.scenes.travel("mainland", true)
	main.get_node("Player").position = Vector2(820, 520)
	await capture("res://.godot/review-mainland.png")
	Game.ui.dialogue("tunde")
	await capture("res://.godot/review-dialogue.png")
	Game.ui.shop("food")
	await capture("res://.godot/review-shop.png")
	Game.ui.close()
	print("VISUAL CAPTURES COMPLETE")
	get_tree().quit()

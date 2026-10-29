extends Node
func _ready() -> void:
	Game.ui.title_mode = true
	Game.ui.title_screen()
	get_tree().paused = true

	if "--smoke-write" in OS.get_cmdline_user_args() or "--smoke-read" in OS.get_cmdline_user_args():
		Game.service("res://scripts/core/ReleaseSmoke.gd", "ReleaseSmoke")

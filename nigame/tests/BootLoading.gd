extends Node
var failures := 0

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/loading-test-settings.cfg"
	Game.settings.set_value("text_scale", 1.0)
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://Scenes/ui/BootLoading.tscn", "Game starts at custom loading scene")
	var image_path: String = ProjectSettings.get_setting("application/boot_splash/image")
	check(image_path == "res://assets/art/loading/ph-night-splash-v1.png" and FileAccess.file_exists(image_path), "Engine startup uses the custom PNG")
	check(not ProjectSettings.get_setting("application/boot_splash/use_filter"), "Splash preserves pixel edges")
	var boot: Control = preload("res://Scenes/ui/BootLoading.tscn").instantiate()
	boot.auto_enter_menu = false
	add_child(boot)
	for frame in range(600):
		await get_tree().process_frame
		if boot.ready_scene != null or boot.failed: break
	check(not boot.failed and boot.ready_scene != null, "Threaded menu loading completes")
	check(boot.progress_bar.value == 100, "Completed loader reports resource readiness")
	check(boot.get_node("SplashArt").texture != null, "Loading screen displays artwork")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/review-loading-screen.png")
	boot.show_error()
	check(boot.retry.visible and not boot.progress_bar.visible, "Loading errors offer retry without false progress")
	boot.begin_loading()
	for frame in range(600):
		await get_tree().process_frame
		if boot.ready_scene != null or boot.failed: break
	check(not boot.failed and boot.ready_scene != null, "Retry loads the menu")
	if boot.ready_scene != null:
		var menu: Node = boot.ready_scene.instantiate()
		add_child(menu)
		for frame in range(3): await get_tree().process_frame
		check(Game.ui.title_page.visible and Game.ui.title_mode, "Loaded menu opens normally")
	print("BOOT LOADING: PASS" if failures == 0 else "BOOT LOADING: FAIL")
	get_tree().quit(0 if failures == 0 else 1)

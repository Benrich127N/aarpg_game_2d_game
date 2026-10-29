extends Node
var started: int = 0

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	started = Time.get_ticks_msec()
	var directory: String = OS.get_executable_path().get_base_dir().path_join("qa")
	DirAccess.make_dir_recursive_absolute(directory)
	Game.settings.path = directory.path_join("settings.cfg")
	Game.save.path = directory.path_join("smoke-slot.json")
	Game.save.enabled = false
	Game.auto_load = false
	Game.ui.start_game(true)
	await get_tree().process_frame
	await get_tree().process_frame
	TimeManager.clock_paused = true
	var success: bool = true
	if "--smoke-write" in OS.get_cmdline_user_args():
		success = Game.scenes.travel("mainland", true)
		Game.dialogue.choose("tunde", "greet")
		success = Game.jobs.start("delivery") and success
		success = Game.jobs.pickup_parcel() and success
		success = Game.jobs.deliver_to("bisi") and success
		success = not Game.jobs.finish(1, true) and success
		success = Game.inventory.purchase("food", "gala") and success
		success = Game.inventory.use_item("gala") and success
		success = Game.wardrobe.buy("indigo") and Game.wardrobe.equip("indigo") and success
		success = Game.wardrobe.transfer(500, true) and success
		success = Game.scenes.travel("room", true) and success
		success = Game.housing.sleep() and success
		Game.save.enabled = true
		success = Game.save.write_save() and success
	else:
		Game.save.enabled = true
		success = Game.save.load_save()
		success = success and Global.cash == 4250 and Game.wardrobe.state.bank == 500 and Game.wardrobe.state.shirt == "indigo"
		success = success and TimeManager.current_day == 2 and Game.jobs.completed == 1 and Game.scenes.location == "room"
		success = success and not Game.jobs.finish(1, true) and Game.dialogue.flags.get("tunde:greet", false)
	# Profile rendered frames after the scene and shader warm-up.
	await get_tree().create_timer(2.0).timeout
	var report: Dictionary = {"passed": success, "engine": Engine.get_version_info().string, "fps": Engine.get_frames_per_second(), "static_memory_bytes": Performance.get_monitor(Performance.MEMORY_STATIC), "nodes": Performance.get_monitor(Performance.OBJECT_NODE_COUNT), "load_ms": Game.scene_load_ms, "elapsed_ms": Time.get_ticks_msec() - started, "renderer": RenderingServer.get_video_adapter_name(), "mode": "write" if "--smoke-write" in OS.get_cmdline_user_args() else "read"}
	var file: FileAccess = FileAccess.open(directory.path_join("report-" + str(report.mode) + ".json"), FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(report, "  "))
	print("RELEASE SMOKE ", report.mode, ": ", "PASS" if success else "FAIL")
	Game.audio.shutdown()
	for frame in range(3): await get_tree().process_frame
	get_tree().quit(0 if success else 1)

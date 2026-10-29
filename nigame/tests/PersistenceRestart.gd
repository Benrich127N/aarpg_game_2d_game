extends Node

func _ready() -> void:
	Game.auto_load = false
	Game.save.path = "res://.godot/restart/slot.json"
	TimeManager.clock_paused = true
	if "write" in OS.get_cmdline_user_args():
		Game.reset()
		Global.cash = 6543
		Global.hunger = 47
		TimeManager.current_day = 3
		TimeManager.current_hour = 21
		TimeManager.current_minute = 15
		Game.inventory.items = {"rice": 2}
		Game.dialogue.flags = {"tunde:greet": true}
		Game.relationships.values = {"tunde": {"friendship": 15, "trust": 6, "romance": 0}}
		Game.quests.objectives = {"first_day": ["talk:tunde", "buy"]}
		Game.housing.furniture = [{"id": "chair", "x": 12, "y": 9}]
		Game.housing.stored = 0
		Game.scenes.location = "mainland"
		Game.jobs.completed = 3
		Game.jobs.attempts = 4
		Game.jobs.active = {"id": "delivery", "token": 4, "started": 4000}
		Game.jobs.delivery_checkpoint = true
		var saved: bool = Game.save.write_save()
		print("RESTART WRITE: ", "PASS" if saved else Game.save.last_error)
		get_tree().quit(0 if saved else 1)
	else:
		Game.auto_load = true
		var main: Node2D = preload("res://scenes/main/Main.tscn").instantiate()
		add_child(main)
		await get_tree().physics_frame
		var restored: bool = Global.cash == 6543 and Global.hunger == 47 and TimeManager.current_day == 3 and TimeManager.current_hour == 21
		restored = restored and Game.inventory.items.get("rice", 0) == 2 and Game.housing.furniture.size() == 1
		restored = restored and Game.dialogue.flags.get("tunde:greet", false) and Game.relationships.values.tunde.friendship == 15
		restored = restored and "talk:tunde" in Game.quests.objectives.first_day and Game.scenes.location == "mainland"
		restored = restored and main.get_node("Player").position == Vector2(320, 384)
		restored = restored and Game.jobs.deliver_to("bisi") and Global.cash == 7293
		restored = restored and not Game.jobs.finish(4, true) and Global.cash == 7293
		print("RESTART READ: ", "PASS" if restored else "FAIL")
		get_tree().quit(0 if restored else 1)

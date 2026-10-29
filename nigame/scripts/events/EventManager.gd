extends Node
signal changed
var schedules: Dictionary = {}
var state: Dictionary = {"weather": "clear", "until": 0, "pending": "", "cooldowns": {}, "next_check": 600, "roll": 0, "positions": {}}
const EVENTS: Dictionary = {
	"rain": {"title": "A sudden shower", "text": "Rain sweeps across the street. Wait under an awning for 20 minutes, or carry on.", "cooldown": 720},
	"traffic": {"title": "Traffic building up", "text": "A neighbour warns that buses are delayed. Wait 30 minutes for it to ease, or keep your plans.", "cooldown": 360},
	"neighbour": {"title": "A helping hand", "text": "A neighbour dropped a bag of shopping. Help for 10 minutes and 5 energy to gain 2 reputation, or politely pass.", "cooldown": 1440}}

func _ready() -> void:
	for id in Game.relationships.NPC_IDS:
		schedules[id] = load("res://resources/characters/%s.tres" % id)
	TimeManager.time_changed.connect(update)

func now() -> int:
	return (TimeManager.current_day - 1) * 1440 + TimeManager.current_hour * 60 + TimeManager.current_minute

func target(id: String) -> Vector2:
	return schedules[id].destination(TimeManager.current_hour)

func update() -> void:
	var minute: int = now()
	if state.weather != "clear" and minute >= int(state.until):
		state.weather = "clear"
	if Game.scenes != null and Game.scenes.location != "mainland":
		for id in schedules:
			var at: Vector2 = target(id)
			state.positions[id] = [at.x, at.y]
	if minute >= int(state.next_check) and Game.scenes != null and Game.scenes.location != "room" and state.pending == "":
		state.next_check = minute + 180
		var candidates: Array = []
		for id in EVENTS:
			if eligible(id): candidates.append(id)
		if not candidates.is_empty():
			state.roll = int(state.roll) + 1
			var rng := RandomNumberGenerator.new()
			rng.seed = minute + int(state.roll) * 101
			# Rain and traffic each get one entry; a neighbour encounter gets two.
			if "neighbour" in candidates: candidates.append("neighbour")
			trigger(candidates[rng.randi_range(0, candidates.size() - 1)])
	changed.emit()

func eligible(id: String) -> bool:
	if not EVENTS.has(id) or state.pending != "": return false
	if Game.scenes == null or Game.scenes.location == "room": return false
	if TimeManager.current_hour < 6 or TimeManager.current_hour >= 20: return false
	return now() >= int(state.cooldowns.get(id, 0))

func trigger(id: String) -> bool:
	if not eligible(id): return false
	state.pending = id
	state.cooldowns[id] = now() + int(EVENTS[id].cooldown)
	if id in ["rain", "traffic"]:
		state.weather = id
		state.until = now() + (90 if id == "rain" else 60)
	Game.message(str(EVENTS[id].title) + " · Open your phone (Tab) for choices.")
	changed.emit()
	return true

func resolve(help: bool) -> bool:
	var id: String = state.pending
	if not EVENTS.has(id): return false
	if help and id == "neighbour" and Global.energy < 5: return false
	state.pending = "" # Consume before effects/signals.
	if help:
		if id == "neighbour":
			Global.change_energy(-5)
			Global.change_reputation(2)
			TimeManager.advance_minutes(10)
		else:
			TimeManager.advance_minutes(20 if id == "rain" else 30)
			state.weather = "clear"
	changed.emit()
	return true

func reset() -> void:
	state = {"weather": "clear", "until": 0, "pending": "", "cooldowns": {}, "next_check": 600, "roll": 0, "positions": {}}

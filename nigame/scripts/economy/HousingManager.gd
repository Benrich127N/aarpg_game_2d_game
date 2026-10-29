extends Node
signal changed
var catalog: Dictionary = {}
var current: String = "room"
var owned: Dictionary = {}
var next_rent_day: int = 8
var arrears: int = 0
var furniture: Array = []
var stored: int = 1

func _ready() -> void:
	for id in ["room", "apartment"]:
		catalog[id] = load("res://resources/properties/%s.tres" % id)

func on_day(day: int) -> void:
	if bool(owned.get(current, false)): return
	if day >= next_rent_day:
		var periods: int = int((day - next_rent_day) / 7.0) + 1
		arrears = mini(1000000000, arrears + periods * int(catalog[current].rent))
		next_rent_day += periods * 7
		Game.message("Rent is due. Visit the housing desk to settle it.")
		changed.emit()

func pay_rent() -> bool:
	if arrears <= 0 or not Global.spend_cash(arrears): return false
	arrears = 0
	changed.emit()
	return true

func rent(id: String) -> bool:
	if not catalog.has(id) or id == current or arrears > 0: return false
	if bool(owned.get(id, false)):
		current = id
	else:
		if not Global.spend_cash(int(catalog[id].rent)): return false
		current = id
	next_rent_day = TimeManager.current_day + 7
	changed.emit()
	return true

func buy(id: String) -> bool:
	if not catalog.has(id) or int(catalog[id].price) <= 0 or bool(owned.get(id, false)) or arrears > 0:
		return false
	if not Global.spend_cash(int(catalog[id].price)): return false
	owned[id] = true
	current = id
	changed.emit()
	return true

func sleep() -> bool:
	if not Game.jobs.active.is_empty():
		Game.message("Finish or cancel your job before sleeping.")
		return false
	var minutes: int = TimeManager.current_hour * 60 + TimeManager.current_minute
	TimeManager.advance_minutes(1440 - minutes + 420)
	Global.change_energy(100)
	Global.change_health(15)
	Game.quests.record("sleep")
	Game.message("A new day. Energy restored.")
	changed.emit()
	return true

func place_chair(cell: Vector2i) -> bool:
	if stored <= 0 or cell.x < 7 or cell.x > 18 or cell.y < 7 or cell.y > 14: return false
	# Keep bed and door approach clear; no overlaps.
	if cell.x < 10 and cell.y < 11: return false
	for entry in furniture:
		if int(entry.x) == cell.x and int(entry.y) == cell.y: return false
	furniture.append({"id": "chair", "x": cell.x, "y": cell.y})
	stored -= 1
	changed.emit()
	return true

func store_chair() -> bool:
	if furniture.is_empty(): return false
	furniture.pop_back()
	stored += 1
	changed.emit()
	return true

func buy_chair() -> bool:
	if stored + furniture.size() >= 12 or not Global.spend_cash(400): return false
	stored += 1
	changed.emit()
	return true

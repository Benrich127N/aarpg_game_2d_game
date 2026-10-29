extends Node
signal location_changed
const DESTINATIONS: Dictionary = {
	"mainland": {"title": "Mainland", "path": "res://scenes/world/mainland/Mainland.tscn", "fare": 100, "minutes": 30, "tier": 0},
	"business": {"title": "Business District", "path": "res://scenes/world/business_district/BusinessDistrict.tscn", "fare": 300, "minutes": 60, "tier": 1},
	"lekki": {"title": "Lekki", "path": "res://scenes/world/lekki/Lekki.tscn", "fare": 500, "minutes": 90, "tier": 1},
	"island": {"title": "Island", "path": "res://scenes/world/island/Island.tscn", "fare": 800, "minutes": 120, "tier": 2},
	"room": {"title": "Home", "path": "res://scenes/world/room/Room.tscn", "fare": 0, "minutes": 0, "tier": 0}}
var location: String = "room"
var spawn: String = "PlayerSpawn"
var pending_position: Vector2 = Vector2(-1, -1)
var busy: bool = false

func travel(target: String, doorway: bool = false) -> bool:
	if busy or not DESTINATIONS.has(target) or target == location: return false
	if not Game.jobs.active.is_empty():
		Game.message("Finish or cancel your job before travelling.")
		return false
	if doorway and not ((location == "room" and target == "mainland") or (location == "mainland" and target == "room")): return false
	if not doorway and target == "room": return false
	if not doorway and Game.progression.tier() < int(DESTINATIONS[target].tier):
		Game.message("Build your career and reputation to unlock this district.")
		return false
	if not ResourceLoader.exists(DESTINATIONS[target].path): return false
	var fare: int = 0 if doorway else int(DESTINATIONS[target].fare)
	if fare > 0 and Global.cash < fare:
		Game.message("Not enough cash for transport.")
		return false
	busy = true
	if fare > 0: Global.spend_cash(fare)
	location = target
	spawn = "DoorSpawn" if doorway and target == "mainland" else "PlayerSpawn"
	pending_position = Vector2(-1, -1)
	if not doorway: TimeManager.advance_minutes(int(DESTINATIONS[target].minutes))
	location_changed.emit()
	busy = false
	Game.message("Arrived: " + str(DESTINATIONS[target].title))
	Game.save.autosave()
	return true

extends Node
signal changed
var values: Dictionary = {}
var greeted_day: Dictionary = {}
const NPC_IDS: Array = ["tunde", "amara", "sade", "bisi", "femi"]

func greet(id: String) -> bool:
	if not id in NPC_IDS or int(greeted_day.get(id, 0)) == TimeManager.current_day:
		return false
	greeted_day[id] = TimeManager.current_day
	var entry: Dictionary = values.get(id, {"friendship": 0, "trust": 0, "romance": 0})
	entry.friendship = clampi(int(entry.friendship) + 5, 0, 100)
	entry.trust = clampi(int(entry.trust) + 2, 0, 100)
	values[id] = entry
	changed.emit()
	return true

func express_interest(id: String) -> bool:
	# Optional, explicitly player-chosen, fictional adult characters only.
	if id != "bisi" or int(values.get(id, {}).get("friendship", 0)) < 20 or int(values.get(id, {}).get("romance", 0)) > 0:
		return false
	var entry: Dictionary = values[id]
	entry.romance = mini(100, int(entry.romance) + 5)
	values[id] = entry
	changed.emit()
	return true

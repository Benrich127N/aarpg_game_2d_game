extends Node
signal changed
var catalog: Dictionary = {}
var objectives: Dictionary = {}
var claimed: Dictionary = {}

func _ready() -> void:
	for id in ["first_day", "neighbour"]:
		catalog[id] = load("res://resources/quests/%s.tres" % id)

func eligible(id: String) -> bool:
	if not catalog.has(id): return false
	var prerequisite: String = catalog[id].prerequisite
	return prerequisite.is_empty() or bool(claimed.get(prerequisite, false))

func record(event: String) -> void:
	for id in catalog:
		if not eligible(id) or bool(claimed.get(id, false)): continue
		if event in catalog[id].objectives:
			var done: Array = objectives.get(id, [])
			if not event in done: done.append(event)
			objectives[id] = done
	changed.emit()

func claim(id: String) -> bool:
	if not eligible(id) or bool(claimed.get(id, false)): return false
	var done: Array = objectives.get(id, [])
	for objective in catalog[id].objectives:
		if not objective in done: return false
	var reward: int = catalog[id].reward
	if Global.cash > 9223372036854775807 - reward: return false
	claimed[id] = true
	Global.add_cash(reward)
	changed.emit()
	return true

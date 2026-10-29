extends Node
signal dialogue_choice_selected(npc_id: String, choice_id: String)
var flags: Dictionary = {}
var data: Dictionary = {}

func _ready() -> void:
	data = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogue.json"))

func choose(id: String, choice: String) -> bool:
	if not data.has(id) or not choice in ["greet", "help", "interest"]: return false
	if choice == "interest" and not Game.relationships.express_interest(id): return false
	if choice == "greet": Game.relationships.greet(id)
	flags[id + ":" + choice] = true
	Game.quests.record("talk:" + id)
	dialogue_choice_selected.emit(id, choice)
	return true

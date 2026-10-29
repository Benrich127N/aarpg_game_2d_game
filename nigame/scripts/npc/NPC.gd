extends "res://scripts/world/Interactable.gd"
# Stable NPC identity and dialogue live in data/dialogue.json.
func _ready() -> void:
	kind = "npc"
	interaction_priority = 10
	super._ready()

extends "res://scripts/world/Interactable.gd"
## Stationary venue cast with shared foot anchoring and matching portrait art.
var art_id := "sade"

func _ready() -> void:
	interaction_priority = 10
	super._ready()
	var sprite := AnimatedSprite2D.new()
	sprite.name = "CharacterSprite"
	sprite.sprite_frames = preload("res://scripts/characters/VenueCast.gd").frames(action_id) if kind == "venue_person" else preload("res://scripts/characters/CharacterArt.gd").frames(art_id)
	sprite.position = preload("res://scripts/characters/CharacterGrounding.gd").VISUAL_ORIGIN
	sprite.scale = Vector2(2, 2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	sprite.play("idle_down")
	for child in get_children():
		if child is Label: child.position.y = -94

func _draw() -> void:
	preload("res://scripts/characters/CharacterGrounding.gd").shadow(self)

extends VBoxContainer
signal selected(item: String)

func _ready() -> void:
	var label := Label.new()
	label.text = "Requested shelf: " + str(Game.jobs.stock_order[Game.jobs.stock_index]).capitalize()
	label.add_theme_font_size_override("font_size", 22)
	add_child(label)
	for item in ["rice", "water", "soap"]:
		var button := Button.new()
		button.text = "Stock " + item.capitalize()
		button.pressed.connect(func() -> void: selected.emit(item))
		add_child(button)

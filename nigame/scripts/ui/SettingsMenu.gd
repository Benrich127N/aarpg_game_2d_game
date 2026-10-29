extends Node

func show_panel() -> void:
	var ui: Node = Game.ui
	ui.frame("Settings", "Volume, readability and motion settings are saved on this device.")
	for bus in ["Music", "Ambience", "SFX"]:
		ui.line(bus + " volume")
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = Game.settings.values[bus]
		slider.custom_minimum_size.y = 32
		slider.value_changed.connect(func(value: float) -> void: Game.settings.set_value(bus, value))
		ui.body.add_child(slider)
	ui.button("Text size: %d%% · change" % int(float(Game.settings.values.text_scale) * 100), func() -> void:
		var scale: float = float(Game.settings.values.text_scale)
		Game.settings.set_value("text_scale", 1.0 if scale >= 1.39 else scale + 0.2)
		show_panel())
	ui.button("Reduced motion: " + ("on" if Game.settings.values.reduced_motion else "off"), func() -> void:
		Game.settings.set_value("reduced_motion", not Game.settings.values.reduced_motion)
		show_panel())
	ui.button("Fullscreen: " + ("on" if Game.settings.values.fullscreen else "off"), func() -> void:
		Game.settings.set_value("fullscreen", not Game.settings.values.fullscreen)
		show_panel())
	ui.line("Keyboard: WASD/arrows move · E interact · I bag · J quests · P contacts · C career · Tab phone · O wardrobe · K save · Esc back/pause.\nController: left stick/D-pad move · A interact/confirm · B back/pause · Y phone · X bag. Menus also support arrows and Enter.")

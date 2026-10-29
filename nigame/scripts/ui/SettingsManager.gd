extends Node
signal changed
var path: String = "user://settings.cfg"
var values: Dictionary = {"Music": 0.45, "Ambience": 0.55, "SFX": 0.65, "text_scale": 1.0, "reduced_motion": false, "fullscreen": false}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config := ConfigFile.new()
	if config.load(path) == OK:
		for key in values:
			var value: Variant = config.get_value("settings", key, values[key])
			if key in ["Music", "Ambience", "SFX"] and (value is float or value is int): values[key] = clampf(float(value), 0, 1)
			elif key == "text_scale" and (value is float or value is int): values[key] = clampf(float(value), 1, 1.4)
			elif key in ["reduced_motion", "fullscreen"] and value is bool: values[key] = value

func set_value(key: String, value: Variant) -> bool:
	if not values.has(key): return false
	if key in ["Music", "Ambience", "SFX", "text_scale"]:
		if not (value is float or value is int) or not is_finite(float(value)): return false
		values[key] = clampf(float(value), 1, 1.4) if key == "text_scale" else clampf(float(value), 0, 1)
	else:
		if not value is bool: return false
		values[key] = value
	apply()
	var config := ConfigFile.new()
	for entry in values: config.set_value("settings", entry, values[entry])
	return config.save(path) == OK

func apply() -> void:
	for bus in ["Music", "Ambience", "SFX"]:
		var index: int = AudioServer.get_bus_index(bus)
		if index >= 0:
			AudioServer.set_bus_volume_db(index, linear_to_db(maxf(0.0001, float(values[bus]))))
			AudioServer.set_bus_mute(index, float(values[bus]) == 0)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	changed.emit()

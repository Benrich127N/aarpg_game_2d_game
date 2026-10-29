extends Node
func _ready() -> void:
	var directory: String = "res://.godot/release-metadata"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var license: FileAccess = FileAccess.open(directory + "/GODOT_LICENSE.txt", FileAccess.WRITE)
	license.store_string(str(Engine.call("get_license_text")))
	license.close()
	var notices: FileAccess = FileAccess.open(directory + "/THIRD_PARTY_NOTICES.txt", FileAccess.WRITE)
	notices.store_string("Godot Engine third-party copyright and licence notices\n\n" + JSON.stringify(Engine.call("get_copyright_info"), "  ") + "\n\n" + JSON.stringify(Engine.call("get_license_info"), "  "))
	notices.close()
	print("Engine licence notices extracted")
	get_tree().quit()

extends Node
## Reproducible visual audit. Writes screenshots/measurements, never player saves.
var evidence_root := "res://docs/ui-audit/"
var output := "res://docs/ui-audit/screenshots/"
var records: Array = []
var main: Node2D
var hud: Node

func settle() -> void:
	for tick in range(5): await get_tree().process_frame

func rect_data(rect: Rect2) -> Array:
	return [snappedf(rect.position.x, 0.1), snappedf(rect.position.y, 0.1), snappedf(rect.size.x, 0.1), snappedf(rect.size.y, 0.1)]

func controls(node: Node, result: Array) -> void:
	if node is Control and node.is_visible_in_tree() and (node is Label or node is Button):
		result.append({"path": str(node.get_path()), "text": node.text, "rect": rect_data(node.get_global_rect()), "font": node.get_theme_font_size("font_size"), "disabled": node.disabled if node is Button else false})
	for child in node.get_children(): controls(child, result)

func player_rect() -> Rect2:
	var bounds := Rect2()
	for sprite in Game.player.layers:
		var texture: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
		var used := Rect2(texture.get_image().get_used_rect())
		if sprite.flip_h: used.position.x = texture.get_width() - used.end.x
		used.position += sprite.offset - texture.get_size() * 0.5 if sprite.centered else sprite.offset
		var transformed: Rect2 = sprite.get_global_transform_with_canvas() * used
		bounds = transformed if bounds.size == Vector2.ZERO else bounds.merge(transformed)
	return bounds

func capture(label: String, hide_notice: bool = true) -> void:
	await settle()
	Game.player.get_node("Camera2D").reset_smoothing()
	Game.player.get_node("Camera2D").force_update_scroll()
	if hide_notice: hud.toast.hide()
	await RenderingServer.frame_post_draw
	var screenshot := get_viewport().get_texture().get_image()
	screenshot.save_png(output + label + ".png")
	var visible_controls: Array = []
	controls(main, visible_controls)
	var top: Control = hud.meters.Health.get_parent().get_parent().get_parent()
	var visible_player := player_rect()
	records.append({"id": label, "window": [get_window().size.x, get_window().size.y], "screenshot": [screenshot.get_width(), screenshot.get_height()], "viewport": rect_data(get_viewport().get_visible_rect()), "text_scale": Game.settings.values.text_scale, "location": Game.scenes.location, "player_rect": rect_data(visible_player), "hud_top": rect_data(top.get_global_rect()), "dock": rect_data(hud.control_dock.get_global_rect()), "player_overlaps_hud": visible_player.intersects(top.get_global_rect()), "player_overlaps_dock": hud.control_dock.visible and visible_player.intersects(hud.control_dock.get_global_rect()), "dialogue_visible": Game.ui.dialogue_card.visible, "dialogue_rect": rect_data(Game.ui.dialogue_card.panel.get_global_rect()), "controls": visible_controls})
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		records.back()["focused"] = {"path": str(focused.get_path()), "rect": rect_data(focused.get_global_rect())}
	records.back()["menu_scroll"] = {"rect": rect_data(Game.ui.page_scroll.get_global_rect()), "position": Game.ui.page_scroll.scroll_vertical, "follow_focus": Game.ui.page_scroll.follow_focus}
	print("AUDIT CAPTURE: " + label)

func location(id: String, at: Vector2 = Vector2(-1, -1)) -> void:
	Game.ui.title_mode = false
	Game.ui.close()
	if get_tree().paused: hud.set_paused(false)
	Game.scenes.location = id
	Game.scenes.spawn = "PlayerSpawn"
	Game.scenes.pending_position = at
	Game.scenes.location_changed.emit()
	await settle()
	for tick in range(4): await get_tree().physics_frame

func sprite_sheet() -> void:
	var sheet := CanvasLayer.new()
	sheet.layer = 100
	add_child(sheet)
	var backdrop := ColorRect.new()
	backdrop.color = Color("182d25")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheet.add_child(backdrop)
	var title := Label.new()
	title.text = "PLAYER: DOWN / UP / PROFILE   |   4 WALK FRAMES   |   3x INTEGER ZOOM"
	title.position = Vector2(32, 24)
	title.add_theme_font_size_override("font_size", 22)
	sheet.add_child(title)
	for row in range(3):
		for column in range(4):
			for layer in Game.player.layers:
				var sprite := Sprite2D.new()
				sprite.texture = layer.sprite_frames.get_frame_texture("walk_" + ["down", "up", "side"][row], column)
				sprite.position = Vector2(128 + column * 160, 160 + row * 180)
				sprite.scale = Vector2(3, 3)
				sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				sheet.add_child(sprite)
	var reference := Label.new()
	reference.text = "NPC FRONT POSES / 3x"
	reference.position = Vector2(744, 80)
	reference.add_theme_font_size_override("font_size", 22)
	sheet.add_child(reference)
	for index in range(5):
		var id: String = Game.relationships.NPC_IDS[index]
		var sprite := Sprite2D.new()
		sprite.texture = preload("res://scripts/characters/CharacterArt.gd").frames(id).get_frame_texture("idle_down", 0)
		sprite.position = Vector2(800 + index % 3 * 160, 220 + index / 3 * 240)
		sprite.scale = Vector2(3, 3)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sheet.add_child(sprite)
		var label := Label.new()
		label.text = id.capitalize()
		label.position = sprite.position + Vector2(-28, 80)
		sheet.add_child(label)
	await capture("29-sprite-closeups")
	sheet.queue_free()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		push_error("UIAudit requires a graphical renderer.")
		get_tree().quit(1)
		return
	if "--after" in OS.get_cmdline_user_args():
		evidence_root += "after/"
		output = evidence_root + "screenshots/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	Game.auto_load = false
	Game.save.enabled = false
	Game.save.path = "res://.godot/ui-audit-no-player-slot.json"
	Game.settings.path = "res://.godot/ui-audit-settings.cfg"
	Game.settings.set_value("text_scale", 1.0)
	Game.settings.set_value("fullscreen", false)
	Game.settings.set_value("reduced_motion", true)
	Game.reset()
	TimeManager.clock_paused = true
	get_window().size = Vector2i(1280, 720)
	main = preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	hud = get_tree().get_first_node_in_group("hud")
	await capture("01-room")
	await location("mainland", Vector2(480, 720))
	await capture("02-player-and-npcs")
	Game.ui.dialogue("tunde")
	await capture("03-dialogue")
	Game.ui.close()
	await location("mainland", Vector2(736, 912))
	await capture("04-street-seating")
	for entry in [["courtyard", Vector2(448, 512), "05-courtyard"], ["provisions", Vector2(864, 512), "06-shop"], ["club", Vector2(640, 536), "07-club"]]:
		await location(entry[0], entry[1])
		await capture(entry[2])
	Game.ui.venue_person("nneka")
	await capture("08-club-conversation")
	Game.ui.job("club")
	await capture("09-job-offer")
	Game.jobs.start("club")
	Game.ui.job("club")
	await capture("10-job-active")
	Game.jobs.cancel()
	Game.ui.close()
	Game.ui.wardrobe()
	await capture("11-wardrobe")
	Game.ui.close()
	Game.ui.phone_view.show_tab("map")
	await capture("12-phone-map")
	Game.ui.body.get_child(Game.ui.body.get_child_count() - 1).grab_focus()
	await capture("12b-phone-map-keyboard-focus")
	Game.ui.close()
	await location("business", Vector2(1120, 448))
	await capture("13-business")
	await location("lekki", Vector2(1120, 448))
	await capture("14-lekki")
	await location("island", Vector2(1120, 448))
	await capture("15-island")
	await location("mainland", Vector2(736, 912))
	TimeManager.current_hour = 20
	TimeManager.time_changed.emit()
	Game.events.state.weather = "rain"
	Game.events.changed.emit()
	await capture("16-night-rain")
	TimeManager.current_hour = 7
	Game.events.state.weather = "clear"
	TimeManager.time_changed.emit()
	Game.events.changed.emit()
	hud.set_paused(true)
	await capture("17-pause")
	Game.ui.settings_menu()
	await capture("18-settings")
	Game.ui.close()
	hud.set_paused(false)
	Game.ui.title_mode = true
	Game.ui.title_screen()
	await capture("19-title")
	Game.ui.title_mode = false
	Game.ui.close()
	Game.settings.set_value("text_scale", 1.4)
	get_window().size = Vector2i(960, 540)
	await location("provisions", Vector2(864, 512))
	await capture("20-small-large-text-hud")
	Game.ui.dialogue("femi")
	await capture("21-small-large-text-dialogue")
	Game.ui.close()
	Game.player.position = Vector2(864, 400)
	await settle()
	Game.ui.dialogue("femi")
	await capture("21b-small-dialogue-near-speaker")
	Game.ui.close()
	Game.ui.settings_menu()
	await capture("22-small-large-text-settings")
	Game.ui.close()
	Game.ui.title_mode = true
	Game.ui.title_screen()
	await capture("23-small-large-text-title")
	Game.ui.title_mode = false
	Game.ui.close()
	get_window().size = Vector2i(800, 600)
	Game.settings.set_value("text_scale", 1.0)
	await location("club", Vector2(640, 536))
	await capture("24-four-three-window")
	get_window().size = Vector2i(640, 360)
	await capture("25-tiny-window")
	get_window().size = Vector2i(1280, 720)
	await location("mainland", Vector2(48, 48))
	await capture("26-northwest-edge")
	await location("mainland", Vector2(1860, 1018))
	await capture("27-southeast-edge")
	get_window().size = Vector2i(960, 540)
	Game.settings.set_value("text_scale", 1.4)
	await location("provisions", Vector2(640, 536))
	Global.cash = 1000000000
	Global.health = 10
	Global.hunger = 20
	Global.energy = 5
	Global.stats_changed.emit()
	await capture("28-critical-needs-long-cash")
	get_window().size = Vector2i(1280, 720)
	await sprite_sheet()
	var file := FileAccess.open(evidence_root + "measurements.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(records, "\t"))
	file.close()
	print("UI AUDIT: COMPLETE · %d captures" % records.size())
	get_tree().quit()

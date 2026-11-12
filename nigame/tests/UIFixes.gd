extends Node
var failures := 0
var checks := 0

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(description)

func settle() -> void:
	for frame in range(5): await get_tree().process_frame

func _ready() -> void:
	Game.auto_load = false
	Game.save.enabled = false
	Game.settings.path = "res://.godot/ui-fixes-settings.cfg"
	Game.settings.set_value("text_scale", 1.0)
	Game.reset()
	TimeManager.clock_paused = true
	var main := preload("res://Scenes/main/Main.tscn").instantiate()
	add_child(main)
	await settle()
	var ui: Node = Game.ui
	var hud: Node = get_tree().get_first_node_in_group("hud")
	check(get_window().min_size == Vector2i(960, 540), "Minimum window preserves readable UI")
	var top: Control = hud.meters.Health.get_parent().get_parent().get_parent()
	check(top.size.y < 100, "Healthy HUD uses less than 100 logical pixels")
	check(not hud.meters.Health.status.visible, "Healthy need descriptions stay in tooltips")
	Global.health = 10
	Global.stats_changed.emit()
	check(hud.meters.Health.status.visible and hud.meters.Health.status.text.begins_with("Critical"), "Critical need advice remains visible")
	Global.health = 100
	Global.stats_changed.emit()
	ui.phone_view.show_tab("map")
	await settle()
	check(ui.body.get_node_or_null("NeighborhoodMap") != null, "Phone map contains landmark diagram")
	check(ui.page_scroll.scroll_vertical == 0 and ui.page_scroll.get_global_rect().encloses(ui.heading.get_global_rect()), "Map opens with heading and diagram in view")
	check(ui.page_scroll.follow_focus, "Shared menus follow keyboard focus")
	var last: Button = ui.body.get_child(ui.body.get_child_count() - 1)
	last.grab_focus()
	await settle()
	check(ui.page_scroll.get_global_rect().encloses(last.get_global_rect()), "Bottom action scrolls into view when focused")
	ui.close()
	ui.job("delivery")
	await settle()
	check(get_viewport().gui_get_focus_owner().text == "Start job", "Job offer defaults to Start job")
	ui.close()
	Game.scenes.travel("mainland", true)
	await settle()
	var detector: Area2D = Game.player.get_node("InteractionArea")
	Game.player.position = Game.events.target("tunde") + Vector2(0, 32)
	for frame in range(5): await get_tree().physics_frame
	check(detector.marker.visible, "Nearby selected target has gold marker")
	var selected: Area2D = detector.target
	var small_font: int = selected.caption.get_theme_font_size("font_size")
	Game.settings.set_value("text_scale", 1.4)
	check(selected.caption.get_theme_font_size("font_size") > small_font, "Target labels follow text size")
	var npc_sprite: AnimatedSprite2D = selected.get_node("CharacterSprite")
	check(npc_sprite.position == Game.player.VISUAL_ORIGIN, "NPC and player use common visual anchor")
	ui.dialogue("tunde")
	for frame in range(3): await get_tree().physics_frame
	check(not detector.marker.visible, "Conversation suppresses target marker")
	ui.close()
	Game.scenes.travel("club", true)
	await settle()
	var portraits: Array = []
	for id in ["nneka", "kemi", "dele"]:
		ui.venue_person(id)
		await settle()
		check(ui.dialogue_card.visible and not ui.overlay.visible, "Venue cast uses bottom dialogue: " + id)
		check(ui.dialogue_card.speaker.text == id.capitalize() and ui.dialogue_card.portrait.texture != null, "Venue speaker identity and portrait: " + id)
		check(ui.dialogue_card.response_buttons.size() <= 3, "Venue response layout stays bounded: " + id)
		var texture: Texture2D = preload("res://scripts/characters/VenueCast.gd").frames(id).get_frame_texture("idle_down", 0)
		portraits.append(texture.get_image().get_data())
		ui.close()
	check(portraits[0] != portraits[1] and portraits[1] != portraits[2], "Club cast has distinct artwork")
	ui.venue_person("nneka")
	await settle()
	ui.dialogue_card.response_buttons[0].pressed.emit()
	await settle()
	check(ui.overlay.visible and not ui.dialogue_card.visible and ui.heading.text == "Club bar shift", "Dialogue transitions cleanly to service panel")
	check(get_viewport().gui_get_focus_owner().text == "Start job", "Club offer focuses primary action")
	Game.jobs.start("club")
	ui.job("club")
	await settle()
	check(get_viewport().gui_get_focus_owner().text.begins_with("Serve "), "Active shift focuses a drink instead of Close or Cancel")
	Game.jobs.cancel()
	ui.close()
	ui.wardrobe()
	await settle()
	var hair: Button = ui.body.get_node("Wardrobe_hair")
	check(hair.text.begins_with("Hair color"), "Wardrobe describes actual color change")
	hair.pressed.emit()
	await settle()
	check(get_viewport().gui_get_focus_owner() == ui.body.get_node("Wardrobe_hair"), "Wardrobe keeps focus on changed property")
	ui.close()
	for id in ["business", "lekki", "island"]:
		Game.scenes.location = id
		Game.scenes.location_changed.emit()
		await settle()
		check(main.district.has_node("DistrictLandmark"), "District has distinct landmark scenery: " + id)
	print("UI FIXES: %s · %d checks" % ["PASS" if failures == 0 else "FAIL", checks])
	get_tree().quit(0 if failures == 0 else 1)

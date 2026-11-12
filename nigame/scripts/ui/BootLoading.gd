extends Control
## A lightweight startup scene; the menu and its art load on the resource thread.
const MENU := "res://Scenes/ui/MainMenu.tscn"
const SPLASH := preload("res://assets/art/loading/ph-night-splash-v1.png")
@export var auto_enter_menu := true
var progress_bar: ProgressBar
var status_label: Label
var retry: Button
var ready_scene: PackedScene
var failed := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("13251f")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var artwork := TextureRect.new()
	artwork.name = "SplashArt"
	artwork.texture = SPLASH
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(artwork)
	var footer := VBoxContainer.new()
	footer.anchor_left = 0.3
	footer.anchor_right = 0.7
	footer.anchor_top = 1.0
	footer.anchor_bottom = 1.0
	footer.offset_top = -62
	footer.offset_bottom = -12
	footer.grow_vertical = Control.GROW_DIRECTION_BEGIN
	footer.add_theme_constant_override("separation", 8)
	add_child(footer)
	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", roundi(14 * float(Game.settings.values.text_scale)))
	status_label.add_theme_color_override("font_color", Color("fff0cc"))
	footer.add_child(status_label)
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size.y = 8
	var track := StyleBoxFlat.new()
	track.bg_color = Color("1c382d")
	track.border_color = Color("627455")
	track.set_border_width_all(1)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("d9b96f")
	progress_bar.add_theme_stylebox_override("background", track)
	progress_bar.add_theme_stylebox_override("fill", fill)
	footer.add_child(progress_bar)
	retry = Button.new()
	retry.text = "Try again"
	retry.hide()
	retry.pressed.connect(begin_loading)
	footer.add_child(retry)
	begin_loading()

func begin_loading() -> void:
	failed = false
	ready_scene = null
	retry.hide()
	progress_bar.show()
	progress_bar.value = 0
	status_label.text = "Opening the mainland…"
	var error := ResourceLoader.load_threaded_request(MENU, "PackedScene")
	if error != OK and error != ERR_BUSY:
		show_error()
		return
	set_process(true)

func _process(_delta: float) -> void:
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(MENU, progress)
	if not progress.is_empty(): progress_bar.value = clampf(float(progress[0]) * 100.0, 0, 100)
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			ready_scene = ResourceLoader.load_threaded_get(MENU) as PackedScene
			if ready_scene == null:
				show_error()
				return
			progress_bar.value = 100
			status_label.text = "Welcome to PH NIGHT"
			set_process(false)
			if auto_enter_menu: enter_menu.call_deferred()
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			show_error()

func enter_menu() -> void:
	# Let the finished loading frame reach the screen before constructing the menu.
	await get_tree().process_frame
	if get_tree().change_scene_to_packed(ready_scene) != OK: show_error()

func show_error() -> void:
	failed = true
	set_process(false)
	status_label.text = "The mainland could not load. Please try again."
	progress_bar.hide()
	retry.show()
	retry.grab_focus()

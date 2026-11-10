extends PanelContainer
const ICON = preload("res://UI/NeedIcon.gd")
const ACCENTS := {"Health": Color("ec9389"), "Hunger": Color("e4bd69"), "Energy": Color("88c5bb")}
var kind: String
var bar: ProgressBar
var title: Label
var amount: Label
var status: Label
var icon: Control
var fill: StyleBoxFlat
var border: StyleBoxFlat
var target: int = -1
var animation: Tween

func setup(stat: String) -> void:
	kind = stat
	name = stat + "Meter"
	mouse_filter = Control.MOUSE_FILTER_PASS
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	border = StyleBoxFlat.new()
	border.bg_color = Color("233831")
	border.border_color = Color("42584a")
	border.set_border_width_all(1)
	border.content_margin_left = 8
	border.content_margin_right = 10
	border.content_margin_top = 8
	border.content_margin_bottom = 8
	add_theme_stylebox_override("panel", border)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	add_child(row)
	icon = ICON.new()
	icon.kind = kind
	icon.accent = ACCENTS[kind]
	row.add_child(icon)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 3)
	row.add_child(column)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 8)
	column.add_child(heading)
	title = Label.new()
	title.text = kind.to_upper()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Color("f4e9cf"))
	heading.add_child(title)
	amount = Label.new()
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount.add_theme_color_override("font_color", Color("f4e9cf"))
	heading.add_child(amount)
	bar = ProgressBar.new()
	bar.name = "Fill"
	bar.custom_minimum_size.y = 12
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color("101f1c")
	background.border_color = Color("0c1714")
	background.set_border_width_all(2)
	bar.add_theme_stylebox_override("background", background)
	fill = StyleBoxFlat.new()
	fill.bg_color = ACCENTS[kind]
	fill.border_color = ACCENTS[kind].lightened(0.2)
	fill.border_width_top = 2
	fill.border_width_bottom = 2
	bar.add_theme_stylebox_override("fill", fill)
	column.add_child(bar)
	status = Label.new()
	column.add_child(status)

func apply_scale(text_scale: float) -> void:
	title.add_theme_font_size_override("font_size", roundi(13 * text_scale))
	amount.add_theme_font_size_override("font_size", roundi(14 * text_scale))
	status.add_theme_font_size_override("font_size", roundi(12 * text_scale))

func update_value(value: int, reduced_motion: bool) -> void:
	var next := clampi(value, 0, 100)
	var critical := next <= 20
	var low := next <= 40
	var accent: Color = Color("f39b83") if critical else (Color("e4bd69") if low else ACCENTS[kind])
	fill.bg_color = accent
	fill.border_color = accent.lightened(0.2)
	border.border_color = accent.darkened(0.35) if low else Color("42584a")
	icon.accent = accent
	icon.queue_redraw()
	amount.text = "%d / 100" % next
	var descriptions: Dictionary = {
		"Health": ["Healthy", "Wounded · take care", "Critical · recover now"],
		"Hunger": ["Well fed", "Hungry · eat soon", "Starving · eat now"],
		"Energy": ["Rested", "Tired · rest soon", "Exhausted · sleep"],
	}
	status.text = descriptions[kind][2 if critical else (1 if low else 0)]
	status.add_theme_color_override("font_color", accent if low else Color("b8c7b6"))
	tooltip_text = "%s: %d / 100. %s. Higher is better." % [kind, next, status.text]
	if kind == "Hunger": tooltip_text += " Food restores fullness; a full bar means well fed."
	if next != target:
		if animation != null: animation.kill()
		if target < 0 or reduced_motion or not is_inside_tree():
			bar.value = next
		else:
			animation = create_tween()
			animation.tween_property(bar, "value", float(next), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		target = next
	elif reduced_motion and not is_equal_approx(bar.value, next):
		if animation != null: animation.kill()
		bar.value = next

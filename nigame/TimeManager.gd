extends Node

@onready var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.wait_time = 1.0  # 1 real second = 1 game minute
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	Global.current_minute += 1
	
	if Global.current_minute >= 60:
		Global.current_minute = 0
		Global.current_hour += 1
		_on_hour_changed()
	
	if Global.current_hour >= 24:
		Global.current_hour = 0
		Global.current_day += 1
		_on_day_changed()
	
	Global.emit_signal("time_changed")

func _on_hour_changed():
	# Streetlights at 6 PM
	if Global.current_hour == 18:
		# TODO: Turn on streetlights
		pass
	
	# Decrease hunger over time
	if Global.current_hour % 4 == 0:
		Global.change_hunger(-10)

func _on_day_changed():
	# Reset energy if player slept
	pass

func get_time_string() -> String:
	var period = "AM" if Global.current_hour < 12 else "PM"
	var display_hour = Global.current_hour if Global.current_hour <= 12 else Global.current_hour - 12
	if display_hour == 0:
		display_hour = 12
	return "%02d:%02d %s" % [display_hour, Global.current_minute, period]

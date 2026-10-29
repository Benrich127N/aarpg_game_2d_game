extends Node

signal time_changed
signal day_changed(day: int)

const MINUTES_PER_DAY: int = 1440
var current_day: int = 1
var current_hour: int = 7
var current_minute: int = 0
var clock_paused: bool = false
var elapsed_seconds: float = 0.0
@export var seconds_per_minute: float = 1.0

func _process(delta: float) -> void:
	if clock_paused:
		return
	elapsed_seconds += delta
	var interval: float = maxf(seconds_per_minute, 0.01)
	var minutes: int = int(elapsed_seconds / interval)
	if minutes > 0:
		elapsed_seconds -= minutes * interval
		advance_minutes(minutes)

func advance_minutes(minutes: int) -> void:
	if minutes <= 0:
		return
	var before: int = current_hour * 60 + current_minute
	var total: int = before + minutes
	var hunger_ticks: int = int(total / 240.0) - int(before / 240.0)
	var days: int = int(total / float(MINUTES_PER_DAY))
	current_day += days
	var remaining: int = total % MINUTES_PER_DAY
	current_hour = int(remaining / 60.0)
	current_minute = remaining % 60
	if hunger_ticks > 0:
		Global.change_hunger(-mini(hunger_ticks, 10) * 10)
	if days > 0:
		day_changed.emit(current_day)
	time_changed.emit()

func get_time_string() -> String:
	var hour: int = current_hour % 12
	if hour == 0:
		hour = 12
	return "%02d:%02d %s" % [hour, current_minute, "AM" if current_hour < 12 else "PM"]

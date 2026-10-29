extends Node

func _ready() -> void:
	for binding in [["interact", JOY_BUTTON_A], ["pause", JOY_BUTTON_B], ["phone", JOY_BUTTON_Y], ["inventory", JOY_BUTTON_X], ["pause", JOY_BUTTON_START], ["move_left", JOY_BUTTON_DPAD_LEFT], ["move_right", JOY_BUTTON_DPAD_RIGHT], ["move_up", JOY_BUTTON_DPAD_UP], ["move_down", JOY_BUTTON_DPAD_DOWN]]:
		var button := InputEventJoypadButton.new()
		button.device = -1
		button.button_index = binding[1]
		InputMap.action_add_event(binding[0], button)
	for binding in [["move_left", JOY_AXIS_LEFT_X, -1.0], ["move_right", JOY_AXIS_LEFT_X, 1.0], ["move_up", JOY_AXIS_LEFT_Y, -1.0], ["move_down", JOY_AXIS_LEFT_Y, 1.0]]:
		var motion := InputEventJoypadMotion.new()
		motion.device = -1
		motion.axis = binding[1]
		motion.axis_value = binding[2]
		InputMap.action_set_deadzone(binding[0], 0.2)
		InputMap.action_add_event(binding[0], motion)

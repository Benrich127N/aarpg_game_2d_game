extends CanvasLayer

@onready var cash_label = $Panel/VBoxContainer/CashLabel
@onready var energy_bar = $Panel/VBoxContainer/EnergyBar
@onready var time_label = $Panel/TimeLabel

func _ready():
	Global.stats_changed.connect(_update_stats)
	Global.time_changed.connect(_update_time)
	_update_stats()
	_update_time()

func _update_stats():
	cash_label.text = _format_naira(Global.cash)
	energy_bar.value = Global.energy

func _update_time():
	time_label.text = "Day %d - %s" % [Global.current_day, TimeManager.get_time_string()]

func _format_naira(amount: float) -> String:
	var string_val = str(int(amount)) # Convert to whole number string
	var result = ""
	var count = 0
	
	# This loop walks through the number backwards and inserts commas
	for i in range(string_val.length() - 1, -1, -1):
		result = string_val[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
			
	return "₦" + result



func _on_button_pressed():
	Global.add_cash(1000)

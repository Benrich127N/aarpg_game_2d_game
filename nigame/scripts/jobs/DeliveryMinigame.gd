extends VBoxContainer
signal cancelled

func _ready() -> void:
	var label := Label.new()
	label.text = "Collect the parcel beside Tunde, then deliver it to Bisi.\nClose this panel and follow the labelled street markers."
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	var button := Button.new()
	button.text = "Cancel delivery (no pay)"
	button.pressed.connect(func() -> void: cancelled.emit())
	add_child(button)

extends Node
signal changed
var achievements: Dictionary = {}

func net_worth() -> int:
	return Global.cash + int(Game.wardrobe.state.bank) + (30000 if bool(Game.housing.owned.get("apartment", false)) else 0)

func tier() -> int:
	if net_worth() >= 100000 and Global.reputation >= 40 and Game.jobs.completed >= 10: return 2
	if net_worth() >= 12000 and Global.reputation >= 10 and Game.jobs.completed >= 3: return 1
	return 0

func title() -> String:
	return ["Hustler", "Professional", "Established"][tier()]

func update() -> void:
	if Game.jobs.completed >= 1: achievements["First pay"] = true
	if Game.jobs.completed >= 3: achievements["Reliable worker"] = true
	if tier() >= 1: achievements["Professional"] = true
	if tier() >= 2: achievements["Established"] = true
	changed.emit()

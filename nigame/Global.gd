extends Node

# Player Stats
var cash: float = 5000.0  # Starting Naira
var energy: int = 100
var hunger: int = 100
var reputation: int = 0

# Social Class Tiers
enum SocialClass { HUSTLER, PROFESSIONAL, BILLIONAIRE }
var current_class: SocialClass = SocialClass.HUSTLER

# Inventory
var inventory: Dictionary = {
	"pure_water": 0,
	"gala": 0,
	"designer_shoes": false
}

# Time tracking
var current_hour: int = 8  # Start at 8 AM
var current_minute: int = 0
var current_day: int = 1

# Signals for UI updates
signal stats_changed
signal time_changed
signal class_upgraded(new_class)

func _ready():
	update_social_class()

func add_cash(amount: float):
	cash += amount
	emit_signal("stats_changed")
	update_social_class()

func spend_cash(amount: float) -> bool:
	if cash >= amount:
		cash -= amount
		emit_signal("stats_changed")
		return true
	return false

func change_energy(amount: int):
	energy = clamp(energy + amount, 0, 100)
	emit_signal("stats_changed")

func change_hunger(amount: int):
	hunger = clamp(hunger + amount, 0, 100)
	emit_signal("stats_changed")

func change_reputation(amount: int):
	reputation += amount
	emit_signal("stats_changed")
	update_social_class()

func update_social_class():
	var old_class = current_class
	
	if cash >= 500000000 and reputation >= 80:  # 500M Naira
		current_class = SocialClass.BILLIONAIRE
	elif cash >= 10000000 and reputation >= 40:  # 10M Naira
		current_class = SocialClass.PROFESSIONAL
	else:
		current_class = SocialClass.HUSTLER
	
	if old_class != current_class:
		emit_signal("class_upgraded", current_class)

func get_class_name() -> String:
	match current_class:
		SocialClass.HUSTLER:
			return "The Hustler"
		SocialClass.PROFESSIONAL:
			return "The Professional"
		SocialClass.BILLIONAIRE:
			return "The Billionaire"
		_:
			return "Unknown"

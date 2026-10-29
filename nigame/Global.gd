extends Node

signal stats_changed

var cash: int = 5000
var energy: int = 100
var hunger: int = 100
var health: int = 100
var reputation: int = 0
var input_blocked: bool = false
var inventory: Dictionary = {"pure_water": 0, "gala": 0}

func add_cash(amount: int) -> bool:
	if amount <= 0 or amount > 9223372036854775807 - cash:
		return false
	cash += amount
	stats_changed.emit()
	return true

func spend_cash(amount: int) -> bool:
	if amount <= 0 or amount > cash:
		return false
	cash -= amount
	stats_changed.emit()
	return true

func change_energy(amount: int) -> void:
	energy = clampi(energy + clampi(amount, -100, 100), 0, 100)
	stats_changed.emit()

func change_hunger(amount: int) -> void:
	hunger = clampi(hunger + clampi(amount, -100, 100), 0, 100)
	stats_changed.emit()

func change_health(amount: int) -> void:
	health = clampi(health + clampi(amount, -100, 100), 0, 100)
	stats_changed.emit()

func change_reputation(amount: int) -> void:
	reputation = clampi(reputation + clampi(amount, -100, 100), 0, 100)
	stats_changed.emit()

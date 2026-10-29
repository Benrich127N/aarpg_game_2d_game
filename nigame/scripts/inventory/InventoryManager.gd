extends Node
signal changed
signal item_purchased(item_id: String, count: int)
signal item_used(item_id: String)
const CAPACITY: int = 8
var items: Dictionary = {}
var catalog: Dictionary = {}
const SHOP_ITEMS: Dictionary = {"food": ["rice", "gala"], "kiosk": ["pure_water", "gala"]}

func _ready() -> void:
	for id in ["gala", "rice", "pure_water"]:
		catalog[id] = load("res://resources/items/%s.tres" % id)

func can_add(id: String, count: int) -> bool:
	if not catalog.has(id) or count <= 0:
		return false
	if not items.has(id) and items.size() >= CAPACITY:
		return false
	return int(items.get(id, 0)) + count <= int(catalog[id].stack_limit)

func add(id: String, count: int = 1) -> bool:
	if not can_add(id, count):
		return false
	items[id] = int(items.get(id, 0)) + count
	changed.emit()
	return true

func remove(id: String, count: int = 1) -> bool:
	if count <= 0 or int(items.get(id, 0)) < count:
		return false
	items[id] -= count
	if int(items[id]) == 0:
		items.erase(id)
	changed.emit()
	return true

func purchase(shop: String, id: String, count: int = 1) -> bool:
	if not SHOP_ITEMS.has(shop) or not id in SHOP_ITEMS[shop] or not can_add(id, count):
		return false
	var cost: int = int(catalog[id].price) * count
	if Global.cash < cost or cost <= 0:
		return false
	# Mutate both sides before notifying observers.
	Global.cash -= cost
	items[id] = int(items.get(id, 0)) + count
	Global.stats_changed.emit()
	changed.emit()
	item_purchased.emit(id, count)
	return true

func use_item(id: String) -> bool:
	if not catalog.has(id) or not remove(id):
		return false
	Global.change_hunger(int(catalog[id].hunger))
	Global.change_energy(int(catalog[id].energy))
	item_used.emit(id)
	return true

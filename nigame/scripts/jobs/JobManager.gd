extends Node
signal job_completed(job_id: String, success: bool)
signal changed
var catalog: Dictionary = {}
var active: Dictionary = {}
var cooldowns: Dictionary = {}
var completed: int = 0
var attempts: int = 0
var stock_order: Array = []
var stock_index: int = 0
var delivery_checkpoint: bool = false
var delivery_received: bool = false

func _ready() -> void:
	for id in ["delivery", "stock"]:
		catalog[id] = load("res://resources/jobs/%s.tres" % id)

func now() -> int:
	return (TimeManager.current_day - 1) * 1440 + TimeManager.current_hour * 60 + TimeManager.current_minute

func reason(id: String) -> String:
	if not catalog.has(id): return "Unknown job."
	if not active.is_empty(): return "Finish or cancel your current job first."
	if completed < int(catalog[id].required_jobs): return "Complete a delivery to unlock this shift."
	if Global.energy < int(catalog[id].energy): return "Rest first: not enough energy."
	if now() < int(cooldowns.get(id, 0)): return "Come back after the job cooldown."
	return ""

func start(id: String) -> bool:
	var blocked: String = reason(id)
	if not blocked.is_empty():
		Game.message(blocked)
		return false
	attempts += 1
	active = {"id": id, "token": attempts, "started": now()}
	Global.change_energy(-int(catalog[id].energy))
	stock_order = ["rice", "water", "soap"]
	stock_order.shuffle()
	stock_index = 0
	delivery_checkpoint = false
	delivery_received = false
	changed.emit()
	return true

func pickup_parcel() -> bool:
	if active.get("id", "") != "delivery": return false
	delivery_checkpoint = true
	changed.emit()
	return true

func deliver_to(npc_id: String) -> bool:
	if npc_id != "bisi" or active.get("id", "") != "delivery" or not delivery_checkpoint:
		return false
	delivery_received = true
	return finish(int(active.token), true)

func match_stock(item: String) -> bool:
	if active.get("id", "") != "stock": return false
	if stock_index >= stock_order.size(): return false
	if item != stock_order[stock_index]:
		finish(int(active.token), false)
		return false
	stock_index += 1
	if stock_index == stock_order.size():
		return finish(int(active.token), true)
	changed.emit()
	return true

func finish(token: int, success: bool) -> bool:
	if active.is_empty() or int(active.token) != token: return false
	var id: String = active.id
	if success and id == "delivery" and (not delivery_checkpoint or not delivery_received): return false
	if success and id == "stock" and stock_index != stock_order.size(): return false
	var data: Resource = catalog[id]
	if success and Global.cash > 9223372036854775807 - int(data.pay): return false
	active.clear() # Consume the attempt before emitting any signals.
	cooldowns[id] = now() + int(data.minutes) + int(data.cooldown)
	if success:
		completed += 1
		Global.add_cash(int(data.pay))
		Global.change_reputation(2)
	TimeManager.advance_minutes(int(data.minutes))
	job_completed.emit(id, success)
	changed.emit()
	Game.message("Job complete: ₦%d paid." % int(data.pay) if success else "Shift failed or cancelled. No pay awarded.")
	return true

func cancel() -> void:
	if not active.is_empty(): finish(int(active.token), false)

extends Node
signal changed
const CLOTHES: Dictionary = {"green": {"title": "Green shirt", "price": 0, "color": "47856c"}, "indigo": {"title": "Indigo shirt", "price": 800, "color": "696da8"}, "coral": {"title": "Coral shirt", "price": 800, "color": "c76c56"}, "gold": {"title": "Gold shirt", "price": 1200, "color": "d4ab54"}}
var state: Dictionary = {"owned": ["green"], "shirt": "green", "skin": 1, "hair": 0, "shoes": 0, "phone_tab": "home", "bank": 0}

func buy(id: String) -> bool:
	if not CLOTHES.has(id) or id in state.owned or int(CLOTHES[id].price) <= 0: return false
	if not Global.spend_cash(int(CLOTHES[id].price)): return false
	state.owned.append(id)
	changed.emit()
	return true

func equip(id: String) -> bool:
	if not id in state.owned: return false
	state.shirt = id
	changed.emit()
	return true

func customize(part: String, value: int) -> bool:
	if not part in ["skin", "hair", "shoes"] or value < 0 or value > 2: return false
	state[part] = value
	changed.emit()
	return true

func reset() -> void:
	state = {"owned": ["green"], "shirt": "green", "skin": 1, "hair": 0, "shoes": 0, "phone_tab": "home", "bank": 0}
	changed.emit()

func transfer(amount: int, deposit: bool) -> bool:
	if amount <= 0 or amount > 1000000000: return false
	if deposit:
		if amount > Global.cash or int(state.bank) > 1000000000 - amount: return false
		Global.cash -= amount
		state.bank = int(state.bank) + amount
	else:
		if amount > int(state.bank) or Global.cash > 1000000000 - amount: return false
		Global.cash += amount
		state.bank = int(state.bank) - amount
	Global.stats_changed.emit()
	changed.emit()
	return true

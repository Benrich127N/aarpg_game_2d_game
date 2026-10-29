extends Node

func show_tab(tab: String = "home") -> void:
	if not tab in ["home", "bank", "contacts", "jobs", "map", "quests"]: tab = "home"
	Game.wardrobe.state.phone_tab = tab
	var ui: Node = Game.ui
	match tab:
		"contacts": ui.contacts()
		"quests": ui.journal()
		"jobs":
			ui.frame("Phone · jobs", "Visit Tunde for deliveries or Femi's stock stand to accept work.")
			for id in Game.jobs.catalog:
				ui.line("%s · ₦%d · %s" % [Game.jobs.catalog[id].title, Game.jobs.catalog[id].pay, Game.jobs.reason(id)])
			if not Game.jobs.active.is_empty(): ui.button("Open current job", func() -> void: ui.job(Game.jobs.active.id))
		"bank":
			ui.frame("Phone · bank", "Cash ₦%d · Bank ₦%d · Net worth ₦%d" % [Global.cash, Game.wardrobe.state.bank, Game.progression.net_worth()])
			for amount in [500, 1000]:
				ui.button("Deposit ₦%d" % amount, func() -> void:
					ui.result(Game.wardrobe.transfer(amount, true), "Deposited.")
					show_tab("bank"))
			ui.button("Withdraw ₦500", func() -> void:
				ui.result(Game.wardrobe.transfer(500, false), "Withdrawn.")
				show_tab("bank"))
		"map":
			ui.frame("Phone · map", "Current location: " + str(Game.scenes.DESTINATIONS[Game.scenes.location].title))
			for id in ["mainland", "business", "lekki", "island"]:
				var destination: Dictionary = Game.scenes.DESTINATIONS[id]
				ui.line("%s · fare ₦%d · %s" % [destination.title, destination.fare, "unlocked" if Game.progression.tier() >= int(destination.tier) else "career locked"])
			ui.line("Mainland: room west; food/kiosk north; Tunde and parcel south; stock stand east; bus stop north-east.")
			for id in Game.events.schedules:
				var at: Vector2 = Game.events.target(id)
				ui.line("%s · scheduled near (%d, %d)" % [Game.dialogue.data[id].name, at.x, at.y])
		_:
			ui.frame("Phone", "Day %d · %s · Weather: %s" % [TimeManager.current_day, TimeManager.get_time_string(), Game.events.state.weather])
			for item in [["Bank", "bank"], ["Contacts", "contacts"], ["Jobs", "jobs"], ["Map", "map"], ["Quests", "quests"]]:
				ui.button(item[0], func() -> void: show_tab(item[1]))
			ui.button("Wardrobe", ui.wardrobe)
			if Game.events.state.pending != "": ui.button("Neighbourhood event", ui.event_panel)
	if tab != "home": ui.button("Phone home", func() -> void: show_tab("home"))

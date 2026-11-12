extends Node

func show_tab(tab: String = "home") -> void:
	if not tab in ["home", "bank", "contacts", "jobs", "map", "quests"]: tab = "home"
	Game.wardrobe.state.phone_tab = tab
	var ui: Node = Game.ui
	match tab:
		"contacts": ui.contacts()
		"quests": ui.journal()
		"jobs":
			ui.frame("Phone · jobs", "Visit Tunde for deliveries, the stockroom inside Sade's shop, or Nneka at the PH Night Club bar for paid shifts. Femi's street stand also offers stock work.")
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
			ui.body.add_child(preload("res://scripts/ui/NeighborhoodMap.gd").new())
			ui.line("North is up. Gold marks your current location. All neighborhood entrances are free; press E at a doorway. Tunde and the parcel stand are south of the food stall. The bus stop is northeast.")
			ui.button("District transport details", district_details)
			ui.button("Find a neighbor", ui.contacts)
			ui.first_button = ui.back_button # Open the diagram at its heading, not scrolled to footer actions.
		_:
			ui.frame("Phone", "Day %d · %s · Weather: %s" % [TimeManager.current_day, TimeManager.get_time_string(), Game.events.state.weather])
			for item in [["Bank", "bank"], ["Contacts", "contacts"], ["Jobs", "jobs"], ["Map", "map"], ["Quests", "quests"]]:
				ui.button(item[0], func() -> void: show_tab(item[1]))
			ui.button("Wardrobe", ui.wardrobe)
			if Game.events.state.pending != "": ui.button("Neighbourhood event", ui.event_panel)
	if tab != "home": ui.button("Phone home", func() -> void: show_tab("home"))

func district_details() -> void:
	var ui: Node = Game.ui
	ui.frame("District transport", "Use the mainland bus stop to travel. Fares advance time; neighborhood doorways are free.")
	for id in ["mainland", "business", "lekki", "island"]:
		var destination: Dictionary = Game.scenes.DESTINATIONS[id]
		ui.line("%s · fare ₦%d · %s" % [destination.title, destination.fare, "unlocked" if Game.progression.tier() >= int(destination.tier) else "career locked"])
	ui.button("Back to neighborhood map", func() -> void: show_tab("map"))

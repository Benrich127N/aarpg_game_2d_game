extends Node
signal message_sent(text: String)
var inventory: Node
var jobs: Node
var relationships: Node
var quests: Node
var dialogue: Node
var housing: Node
var progression: Node
var scenes: Node
var save: Node
var ui: Node
var player: CharacterBody2D
var auto_load: bool = true
var booted: bool = false
var modal_open: bool = false
var previous_clock_pause: bool = false

func service(path: String, service_name: String) -> Node:
	var node: Node = load(path).new()
	node.name = service_name
	add_child(node)
	return node

func _ready() -> void:
	inventory = service("res://scripts/inventory/InventoryManager.gd", "InventoryManager")
	jobs = service("res://scripts/jobs/JobManager.gd", "JobManager")
	relationships = service("res://scripts/relationships/RelationshipManager.gd", "RelationshipManager")
	quests = service("res://scripts/quests/QuestManager.gd", "QuestManager")
	dialogue = service("res://scripts/dialogue/DialogueManager.gd", "DialogueManager")
	housing = service("res://scripts/economy/HousingManager.gd", "HousingManager")
	progression = service("res://scripts/economy/SocialClassManager.gd", "SocialClassManager")
	scenes = service("res://scripts/core/SceneManager.gd", "SceneManager")
	save = service("res://scripts/save/SaveManager.gd", "SaveManager")
	jobs.job_completed.connect(_job_finished)
	inventory.item_purchased.connect(func(_id: String, _count: int) -> void: quests.record("buy"))
	inventory.item_used.connect(func(_id: String) -> void: quests.record("eat"))
	TimeManager.day_changed.connect(housing.on_day)
	Global.stats_changed.connect(progression.update)
	housing.changed.connect(progression.update)
	jobs.changed.connect(progression.update)

func _job_finished(_id: String, success: bool) -> void:
	if success: quests.record("job")

func message(text: String) -> void:
	message_sent.emit(text)

func open_modal() -> void:
	if modal_open: return
	modal_open = true
	previous_clock_pause = TimeManager.clock_paused
	TimeManager.clock_paused = true
	Global.input_blocked = true

func close_modal() -> void:
	if not modal_open: return
	modal_open = false
	TimeManager.clock_paused = previous_clock_pause
	Global.input_blocked = false

func reset() -> void:
	Global.cash = 5000
	Global.energy = 100
	Global.hunger = 100
	Global.health = 100
	Global.reputation = 0
	TimeManager.current_day = 1
	TimeManager.current_hour = 7
	TimeManager.current_minute = 0
	TimeManager.elapsed_seconds = 0
	inventory.items = {}
	jobs.active = {}
	jobs.cooldowns = {}
	jobs.completed = 0
	jobs.attempts = 0
	jobs.stock_order = []
	jobs.stock_index = 0
	jobs.delivery_checkpoint = false
	relationships.values = {}
	relationships.greeted_day = {}
	quests.objectives = {}
	quests.claimed = {}
	dialogue.flags = {}
	housing.current = "room"
	housing.owned = {}
	housing.next_rent_day = 8
	housing.arrears = 0
	housing.furniture = []
	housing.stored = 1
	progression.achievements = {}
	scenes.location = "room"
	scenes.spawn = "PlayerSpawn"
	scenes.pending_position = Vector2(-1, -1)
	Global.stats_changed.emit()
	TimeManager.time_changed.emit()

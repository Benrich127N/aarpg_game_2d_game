extends Node
var music: AudioStreamPlayer
var ambience: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var streams: Dictionary = {}
var effect_index: int = 0
var environment: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Music", "Ambience", "SFX"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	for id in ["music", "room", "market", "rain", "traffic", "step", "click", "bus"]:
		streams[id] = synth(id)
	music = channel("Music", -18)
	music.stream = streams.music
	music.play()
	ambience = channel("Ambience", -16)
	for index in range(4): effects.append(channel("SFX", -12))
	Game.events.changed.connect(update_environment)
	Game.scenes.location_changed.connect(update_environment)
	Game.settings.apply()
	update_environment()

func channel(bus: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	player.volume_db = volume
	add_child(player)
	return player

func update_environment() -> void:
	var id: String = "room" if Game.scenes.location == "room" else (str(Game.events.state.weather) if Game.events.state.weather != "clear" else "market")
	if environment == id: return
	environment = id
	ambience.stream = streams[id]
	ambience.play()

func sfx(id: String) -> void:
	if not streams.has(id): return
	var player: AudioStreamPlayer = effects[effect_index % effects.size()]
	effect_index += 1
	player.stream = streams[id]
	player.play()

func synth(id: String) -> AudioStreamWAV:
	const RATE: int = 11025
	var seconds: float = 6.0 if id == "music" else 2.0 if id in ["room", "market", "rain", "traffic"] else 0.35
	var count: int = int(RATE * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var filtered: float = 0
	for index in range(count):
		var time: float = float(index) / RATE
		var noise: float = rng.randf_range(-1, 1)
		filtered = filtered * 0.94 + noise * 0.06
		var sample: float = 0
		match id:
			"music":
				# Original 6-second pentatonic phrase with interlocking 3/2 percussion.
				var beat: float = fmod(time, 0.375)
				var pitch: float = [220.0, 261.63, 293.66, 329.63, 392.0, 329.63, 293.66, 261.63][int(time / 0.75) % 8]
				sample = sin(TAU * pitch * time) * exp(-beat * 12) * 0.13
				sample += sin(TAU * 70 * time) * exp(-fmod(time, 0.75) * 32) * 0.25
				sample += noise * exp(-fmod(time + 0.125, 0.25) * 100) * 0.08
			"rain": sample = noise * 0.14 + filtered * 0.4
			"traffic": sample = filtered * 0.45 + sin(TAU * 65 * time) * 0.06
			"market": sample = filtered * 0.25 + sin(TAU * 120 * time) * 0.015
			"room": sample = filtered * 0.06 + sin(TAU * 55 * time) * 0.015
			"step": sample = noise * exp(-time * 60) * 0.32
			"click": sample = sin(TAU * 660 * time) * exp(-time * 35) * 0.3
			"bus": sample = (sin(TAU * 220 * time) + sin(TAU * 277.18 * time)) * exp(-time * 8) * 0.15
		if id not in ["step", "click", "bus"]:
			# Fade both loop edges to silence to avoid an audible discontinuity.
			sample *= minf(1, minf(time / 0.02, (seconds - time) / 0.02))
		data.encode_s16(index * 2, int(clampf(sample, -0.95, 0.95) * 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = data
	if id not in ["step", "click", "bus"]:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = count
	return stream

func shutdown() -> void:
	for player in [music, ambience] + effects:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	streams.clear()

func _exit_tree() -> void:
	shutdown()

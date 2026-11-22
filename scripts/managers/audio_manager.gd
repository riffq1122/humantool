extends Node
## Global audio manager: crossfades looping BGM tracks, plays voice blips
## for dialogue/typewriter text, and pools SFX on the SFX bus.

const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"

const BGM_BASE_DB := -14.0
const SILENT_DB := -40.0
const SFX_POOL_SIZE := 8
const VOICE_POOL_SIZE := 2

const BGM_PATHS: Dictionary = {
	&"menu": "res://assets/audio/music/3. Fun Time.ogg",
	&"cutscene": "res://assets/audio/music/5. The Shepherd.ogg",
	&"dialogue": "res://assets/audio/music/7. Riding Horse.ogg",
	&"crafting": "res://assets/audio/music/4. Solve Puzzle.ogg",
	&"showcase": "res://assets/audio/music/2. Green Field.ogg",
	&"negotiation": "res://assets/audio/music/1. Playground.ogg",
}

const SFX_PATHS: Dictionary = {
	&"ui_click": "res://assets/audio/sfx/pop_1.wav",
	&"card_pick": "res://assets/audio/sfx/card_draw_1.wav",
	&"card_fan": "res://assets/audio/sfx/card_fan.wav",
	&"preview_match": "res://assets/audio/sfx/heart_collect.wav",
	&"craft_step_1": "res://assets/audio/sfx/match_synth_1.wav",
	&"craft_step_2": "res://assets/audio/sfx/match_synth_2.wav",
	&"craft_step_3": "res://assets/audio/sfx/match_synth_3.wav",
	&"craft_final": "res://assets/audio/sfx/match_synth_4.wav",
	&"fanfare": "res://assets/audio/sfx/gem_collect.wav",
}

const ILMUAN_BLIP_PATHS: Array[String] = [
	"res://assets/audio/sfx/bleep001.ogg",
	"res://assets/audio/sfx/bleep007.ogg",
	"res://assets/audio/sfx/bleep010.ogg",
]

const RAIL_BLIP_PATHS: Array[String] = [
	"res://assets/audio/sfx/bleep017.ogg",
	"res://assets/audio/sfx/bleep018.ogg",
	"res://assets/audio/sfx/bleep019.ogg",
]

const NARRATOR_BLIP_PATH := "res://assets/audio/sfx/bleep010.ogg"

var _bgm_streams: Dictionary = {}
var _sfx_streams: Dictionary = {}
var _ilmuan_blips: Array[AudioStream] = []
var _rail_blips: Array[AudioStream] = []
var _narrator_blip: AudioStream = null

var _bgm_players: Array[AudioStreamPlayer] = []
var _active_bgm_idx: int = 0
var _active_bgm_key: StringName = &""
var _bgm_tween: Tween = null

var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_idx: int = 0

var _voice_players: Array[AudioStreamPlayer] = []
var _next_voice_idx: int = 0
var _voice_burst_tween: Tween = null


func _ready() -> void:
	_ensure_audio_buses()
	_sync_settings_to_buses()
	_load_audio_assets()
	_create_audio_players()


func play_bgm(track_key: StringName, fade_duration: float = 0.6) -> void:
	var stream := _bgm_streams.get(track_key) as AudioStream
	if stream == null:
		return

	var current_player := _bgm_players[_active_bgm_idx]
	if track_key == _active_bgm_key and current_player.playing:
		return

	if _bgm_tween != null and _bgm_tween.is_valid():
		_bgm_tween.kill()
		_bgm_tween = null

	var old_idx := _active_bgm_idx
	var old_player := _bgm_players[old_idx]
	var new_idx := 1 - old_idx
	var new_player := _bgm_players[new_idx]

	_active_bgm_idx = new_idx
	_active_bgm_key = track_key

	new_player.stream = stream
	if fade_duration <= 0.0:
		old_player.stop()
		new_player.volume_db = BGM_BASE_DB
		new_player.play()
		return

	var was_old_playing := old_player.playing
	new_player.volume_db = SILENT_DB if was_old_playing else -18.0
	new_player.play()

	_bgm_tween = create_tween().set_parallel(true)
	_bgm_tween.tween_property(new_player, "volume_db", BGM_BASE_DB, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if was_old_playing:
		_bgm_tween.tween_property(old_player, "volume_db", SILENT_DB, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		_bgm_tween.chain().tween_callback(func() -> void:
			if _active_bgm_idx != old_idx:
				old_player.stop()
		)


func play_voice_blip(speaker: String, expression: String = "") -> void:
	var key := speaker.strip_edges().to_lower()
	var expr := expression.strip_edges().to_lower()
	var stream: AudioStream = null
	var pitch := 1.0
	var volume_db := 2.0

	if key == "ilmuan":
		if not _ilmuan_blips.is_empty():
			stream = _ilmuan_blips[randi() % _ilmuan_blips.size()]
		var base_pitch := 0.98
		if expr == "kaget":
			base_pitch = 1.12
		elif expr == "ketawa" or expr == "hehe":
			base_pitch = 1.05
		elif expr == "melet":
			base_pitch = 1.08
		pitch = base_pitch + randf_range(-0.04, 0.04)
	elif key == "rail" or key == "???" or key.contains("‿"):
		if not _rail_blips.is_empty():
			stream = _rail_blips[randi() % _rail_blips.size()]
		var base_pitch := 1.12
		if expr in ["kaget", "senang", "baju", "menor"]:
			base_pitch = 1.24
		elif expr == "tanya":
			base_pitch = 1.18
		pitch = base_pitch + randf_range(-0.05, 0.05)
	else:
		stream = _narrator_blip
		pitch = randf_range(0.83, 0.87)
		volume_db = -4.0

	if stream == null:
		return
	_play_on_voice_pool(stream, pitch, volume_db)


func play_voice_burst(speaker: String, syllables: int = 5, expression: String = "") -> void:
	stop_voice_burst()
	var count := maxi(syllables, 1)
	play_voice_blip(speaker, expression)
	if count == 1:
		return

	_voice_burst_tween = create_tween()
	for i in range(1, count):
		_voice_burst_tween.tween_interval(0.068)
		_voice_burst_tween.tween_callback(func() -> void:
			play_voice_blip(speaker, expression)
		)


func play_spawn_confused_sfx() -> void:
	stop_voice_burst()
	if _ilmuan_blips.is_empty():
		return

	var pitches: Array[float] = [0.95, 1.08, 1.22, 1.38]
	var delays: Array[float] = [0.13, 0.13, 0.15]
	var blip := _ilmuan_blips[0]

	_play_on_voice_pool(blip, pitches[0], 2.0)
	_voice_burst_tween = create_tween()
	for i in range(1, pitches.size()):
		var target_pitch := pitches[i]
		_voice_burst_tween.tween_interval(delays[i - 1])
		_voice_burst_tween.tween_callback(func() -> void:
			var next_blip := _ilmuan_blips[mini(i, _ilmuan_blips.size() - 1)]
			_play_on_voice_pool(next_blip, target_pitch, 2.0)
		)


func stop_voice_burst() -> void:
	if _voice_burst_tween != null and _voice_burst_tween.is_valid():
		_voice_burst_tween.kill()
	_voice_burst_tween = null


func play_sfx(
	sfx_key: StringName,
	pitch_min: float = 0.96,
	pitch_max: float = 1.04,
	volume_db: float = 0.0
) -> void:
	var stream := _sfx_streams.get(sfx_key) as AudioStream
	if stream == null:
		return

	var player := _sfx_players[_next_sfx_idx]
	_next_sfx_idx = (_next_sfx_idx + 1) % _sfx_players.size()
	player.stream = stream
	player.pitch_scale = randf_range(minf(pitch_min, pitch_max), maxf(pitch_min, pitch_max))
	player.volume_db = volume_db
	player.play()


func _play_on_voice_pool(stream: AudioStream, pitch: float, volume_db: float) -> void:
	var player := _voice_players[_next_voice_idx]
	_next_voice_idx = (_next_voice_idx + 1) % _voice_players.size()
	player.stream = stream
	player.pitch_scale = maxf(pitch, 0.1)
	player.volume_db = volume_db
	player.play()


func _ensure_audio_buses() -> void:
	for bus_name: StringName in [BUS_MUSIC, BUS_SFX]:
		if AudioServer.get_bus_index(bus_name) == -1:
			var idx := AudioServer.bus_count
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, &"Master")


func _sync_settings_to_buses() -> void:
	var settings := get_node_or_null("/root/GameSettings")
	if settings != null:
		settings.call("set_music_volume", settings.get("music_volume"))
		settings.call("set_sfx_volume", settings.get("sfx_volume"))


func _load_audio_assets() -> void:
	for key: StringName in BGM_PATHS:
		var path := String(BGM_PATHS[key])
		var stream := _safe_load_audio(path)
		if stream != null:
			var ogg := stream as AudioStreamOggVorbis
			if ogg != null:
				ogg.loop = true
			_bgm_streams[key] = stream

	for key: StringName in SFX_PATHS:
		var path := String(SFX_PATHS[key])
		var stream := _safe_load_audio(path)
		if stream != null:
			_sfx_streams[key] = stream

	for path in ILMUAN_BLIP_PATHS:
		var stream := _safe_load_audio(path)
		if stream != null:
			_ilmuan_blips.append(stream)

	for path in RAIL_BLIP_PATHS:
		var stream := _safe_load_audio(path)
		if stream != null:
			_rail_blips.append(stream)

	_narrator_blip = _safe_load_audio(NARRATOR_BLIP_PATH)


func _safe_load_audio(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: file audio tidak ditemukan: %s" % path)
		return null
	var stream := ResourceLoader.load(path) as AudioStream
	if stream == null:
		push_warning("AudioManager: gagal memuat audio: %s" % path)
	return stream


func _create_audio_players() -> void:
	for i in range(2):
		var bgm_player := AudioStreamPlayer.new()
		bgm_player.name = "BgmPlayer%d" % i
		bgm_player.bus = BUS_MUSIC
		bgm_player.volume_db = SILENT_DB
		add_child(bgm_player)
		_bgm_players.append(bgm_player)

	for i in range(SFX_POOL_SIZE):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SfxPlayer%d" % i
		sfx_player.bus = BUS_SFX
		add_child(sfx_player)
		_sfx_players.append(sfx_player)

	for i in range(VOICE_POOL_SIZE):
		var voice_player := AudioStreamPlayer.new()
		voice_player.name = "VoicePlayer%d" % i
		voice_player.bus = BUS_SFX
		add_child(voice_player)
		_voice_players.append(voice_player)

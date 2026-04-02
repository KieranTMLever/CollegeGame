extends Node
## GameData — Autoload singleton that holds all persistent game state,
## audio settings, and control bindings.

# ── Game State ────────────────────────────────────────────────────────────────
var score: int = 0
var high_score: int = 0
var lives: int = 3
var current_level: int = 1
var time_remaining: float = 0.0
var collected_this_level: int = 0
var difficulty: int = 1  # 1 = Normal, 2 = Hard

# ── Audio Settings ─────────────────────────────────────────────────────────────
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0

# ── Level scenes ──────────────────────────────────────────────────────────────
const LEVEL_SCENES: Array[String] = [
	"res://scenes/Level1.tscn",
	"res://scenes/Level2.tscn",
	"res://scenes/Level3.tscn",
]

const LEVEL_NAMES: Array[String] = [
	"The Library",
	"The Labs",
	"Finals Week",
]

const LEVEL_TIMES: Array[float] = [90.0, 70.0, 50.0]

# ── Default control actions and their physical keycodes ───────────────────────
const DEFAULT_BINDINGS: Dictionary = {
	"move_left":  KEY_A,
	"move_right": KEY_D,
	"jump":       KEY_SPACE,
	"pause":      KEY_ESCAPE,
}

const ACTION_LABELS: Dictionary = {
	"move_left":  "Move Left",
	"move_right": "Move Right",
	"jump":       "Jump",
	"pause":      "Pause",
}

# ── Initialisation ─────────────────────────────────────────────────────────────
func _ready() -> void:
	load_settings()

# ── Helpers ────────────────────────────────────────────────────────────────────
func reset_game() -> void:
	score = 0
	lives = 3
	current_level = 1
	collected_this_level = 0

func add_score(points: int) -> void:
	score += points
	if score > high_score:
		high_score = score

func lose_life() -> bool:
	lives -= 1
	return lives <= 0

## Returns true when there IS a next level to go to.
func advance_level() -> bool:
	current_level += 1
	return current_level <= LEVEL_SCENES.size()

func get_level_scene() -> String:
	if current_level >= 1 and current_level <= LEVEL_SCENES.size():
		return LEVEL_SCENES[current_level - 1]
	return ""

func get_level_name() -> String:
	if current_level >= 1 and current_level <= LEVEL_NAMES.size():
		return LEVEL_NAMES[current_level - 1]
	return "Unknown"

func get_level_time() -> float:
	if current_level >= 1 and current_level <= LEVEL_TIMES.size():
		var t: float = LEVEL_TIMES[current_level - 1]
		if difficulty == 2:
			t *= 0.7
		return t
	return 60.0

# ── Audio ──────────────────────────────────────────────────────────────────────
func apply_volumes() -> void:
	if AudioServer.get_bus_count() < 3:
		return
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx_volume))

# ── Persistence ────────────────────────────────────────────────────────────────
func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music",  music_volume)
	cfg.set_value("audio", "sfx",    sfx_volume)
	cfg.set_value("game",  "high_score", high_score)
	for action in DEFAULT_BINDINGS:
		var events := InputMap.action_get_events(action)
		var kc: int = DEFAULT_BINDINGS[action]
		for ev in events:
			if ev is InputEventKey:
				kc = ev.physical_keycode
				break
		cfg.set_value("controls", action, kc)
	cfg.save("user://settings.cfg")

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	master_volume = cfg.get_value("audio", "master", 1.0)
	music_volume  = cfg.get_value("audio", "music",  0.7)
	sfx_volume    = cfg.get_value("audio", "sfx",    1.0)
	high_score    = cfg.get_value("game",  "high_score", 0)
	for action in DEFAULT_BINDINGS:
		var kc: int = cfg.get_value("controls", action, DEFAULT_BINDINGS[action])
		_remap_action(action, kc)
	apply_volumes()

func remap_action(action: String, keycode: int) -> void:
	_remap_action(action, keycode)
	save_settings()

func _remap_action(action: String, keycode: int) -> void:
	InputMap.action_erase_events(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action, ev)

func get_action_key_name(action: String) -> String:
	var events := InputMap.action_get_events(action)
	for ev in events:
		if ev is InputEventKey:
			return OS.get_keycode_string(ev.get_physical_keycode_with_modifiers())
	return "???"

extends Node2D
## Level — Base script for all levels.  Generates the level from data arrays,
## manages the timer, tracks collectibles, and handles win/lose transitions.

signal level_complete
signal game_over_signal

# ── Data injected by sub-scenes (override in Level*.tscn) ─────────────────────
@export var level_number: int = 1

# Tile size in pixels
const TILE: int = 16

# Each platform entry: [col, row, width_in_tiles, height_in_tiles]
# row 0 = y:0, positive row = lower on screen
var platform_data: Array = []

# Each enemy entry: [tile_col, tile_row, speed_multiplier, face_right]
var enemy_data: Array = []

# Each collectible entry: [tile_col, tile_row, is_boost]
var collectible_data: Array = []

# Each hazard entry: [tile_col, tile_row]
var hazard_data: Array = []

# Exit door tile position
var exit_pos: Vector2 = Vector2(18, 6)

# Background gradient colours
var bg_top:    Color = Color(0.08, 0.08, 0.20)
var bg_bottom: Color = Color(0.12, 0.10, 0.25)
var bg_detail: Color = Color(0.15, 0.12, 0.30)

# ── Runtime ────────────────────────────────────────────────────────────────────
var _time_left: float   = 90.0
var _total_collectibles: int = 0
var _collected: int     = 0
var _player_ref: Node   = null
var _hud: Node          = null
var _is_running: bool   = true
var _paused: bool       = false

# Untyped so duck-typing works for the custom signals on PauseMenu's script
@onready var _pause_menu = $PauseMenu

# Preloaded scenes
const PlayerScene:      PackedScene = preload("res://scenes/Player.tscn")
const EnemyScene:       PackedScene = preload("res://scenes/Enemy.tscn")
const CollectibleScene: PackedScene = preload("res://scenes/Collectible.tscn")
const HazardScene:      PackedScene = preload("res://scenes/Hazard.tscn")
const ExitDoorScene:    PackedScene = preload("res://scenes/ExitDoor.tscn")
const HUDScene:         PackedScene = preload("res://scenes/HUD.tscn")

func _ready() -> void:
	_time_left = GameData.get_level_time()
	_setup_level_data()
	_build_level()
	_spawn_player()
	_spawn_hud()
	_update_hud()
	_pause_menu.hide()
	_pause_menu.resume_requested.connect(_on_resume)
	_pause_menu.quit_requested.connect(_on_quit_to_menu)

func _setup_level_data() -> void:
	# Override in subclass or set via exported variables; default is Level 1 layout
	pass

func _add_background() -> void:
	var bg := ColorRect.new()
	bg.position = Vector2.ZERO
	bg.size = Vector2(320, 180)
	bg.color = bg_bottom
	bg.z_index = -100
	add_child(bg)
	# Decorative pixel details vary by level
	match level_number:
		1: _add_library_bg()
		2: _add_lab_bg()
		3: _add_finals_bg()

func _add_library_bg() -> void:
	# Book shelves silhouette as simple rects
	for i in range(6):
		var shelf := ColorRect.new()
		shelf.position = Vector2(float(i) * 52.0, 20.0)
		shelf.size = Vector2(40.0, 60.0)
		shelf.color = Color(0.12, 0.09, 0.18)
		shelf.z_index = -90
		add_child(shelf)
		for j in range(5):
			var book := ColorRect.new()
			book.position = Vector2(float(i) * 52.0 + float(j) * 8.0, 22.0)
			book.size = Vector2(7.0, 50.0)
			book.color = Color(
				0.2 + float(j) * 0.07,
				0.1 + float(i) * 0.04,
				0.3 - float(j) * 0.03)
			book.z_index = -89
			add_child(book)

func _add_lab_bg() -> void:
	# Equipment silhouettes
	for i in range(4):
		var table := ColorRect.new()
		table.position = Vector2(float(i) * 78.0, 70.0)
		table.size = Vector2(60.0, 8.0)
		table.color = Color(0.09, 0.18, 0.12)
		table.z_index = -90
		add_child(table)
		var flask := ColorRect.new()
		flask.position = Vector2(float(i) * 78.0 + 25.0, 55.0)
		flask.size = Vector2(10.0, 16.0)
		flask.color = Color(0.1, 0.35, 0.18)
		flask.z_index = -89
		add_child(flask)

func _add_finals_bg() -> void:
	# Stressed faces / paper storm
	for i in range(8):
		var paper := ColorRect.new()
		paper.position = Vector2(float(i) * 40.0 + 5.0, 30.0 + float(i % 3) * 20.0)
		paper.rotation_degrees = float(i) * 15.0
		paper.size = Vector2(14.0, 10.0)
		paper.color = Color(0.22, 0.10, 0.10)
		paper.z_index = -90
		add_child(paper)

func _build_level() -> void:
	# ── Platforms ──────────────────────────────────────────────────────────
	for pd in platform_data:
		_spawn_platform(pd[0], pd[1], pd[2], pd[3])

	# ── Enemies ────────────────────────────────────────────────────────────
	for ed in enemy_data:
		_spawn_enemy(ed[0], ed[1], ed[2], ed[3])

	# ── Collectibles ───────────────────────────────────────────────────────
	_total_collectibles = collectible_data.size()
	for cd in collectible_data:
		_spawn_collectible(cd[0], cd[1], cd[2])

	# ── Hazards ────────────────────────────────────────────────────────────
	for hd in hazard_data:
		_spawn_hazard(hd[0], hd[1])

	# ── Exit door ──────────────────────────────────────────────────────────
	var door := ExitDoorScene.instantiate()
	door.position = Vector2(exit_pos.x * TILE + TILE / 2, exit_pos.y * TILE)
	door.door_entered.connect(_on_door_entered)
	add_child(door)

func _spawn_platform(col: int, row: int, w: int, h: int) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(col * TILE, row * TILE)
	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size = Vector2(w * TILE, h * TILE)
	shape.shape = rect
	shape.position = Vector2(w * TILE / 2.0, h * TILE / 2.0)
	body.add_child(shape)
	# Visual
	var vis := ColorRect.new()
	vis.size     = Vector2(w * TILE, h * TILE)
	vis.color    = _platform_color()
	body.add_child(vis)
	# Top highlight
	var hi := ColorRect.new()
	hi.size     = Vector2(w * TILE, 2)
	hi.color    = _platform_highlight()
	hi.position = Vector2(0, 0)
	body.add_child(hi)
	add_child(body)

func _platform_color() -> Color:
	match level_number:
		1: return Color(0.30, 0.22, 0.45)  # Library purple
		2: return Color(0.15, 0.30, 0.20)  # Labs green
		3: return Color(0.35, 0.12, 0.12)  # Finals red
		_: return Color(0.25, 0.20, 0.40)

func _platform_highlight() -> Color:
	match level_number:
		1: return Color(0.55, 0.45, 0.75)
		2: return Color(0.35, 0.60, 0.40)
		3: return Color(0.65, 0.25, 0.25)
		_: return Color(0.50, 0.45, 0.65)

func _spawn_enemy(col: int, row: int, speed_mult: float, face_right: bool) -> void:
	var enemy: CharacterBody2D = EnemyScene.instantiate()
	enemy.position = Vector2(col * TILE + TILE / 2, row * TILE - TILE)
	enemy.patrol_speed = 35.0 * speed_mult
	enemy.face_right_start = face_right
	add_child(enemy)

func _spawn_collectible(col: int, row: int, is_boost: bool) -> void:
	var c: Area2D = CollectibleScene.instantiate()
	c.position = Vector2(col * TILE + TILE / 2, row * TILE - TILE / 2)
	c.is_boost  = is_boost
	c.points    = 50 if is_boost else 10
	c.picked_up.connect(_on_item_picked_up)
	add_child(c)

func _spawn_hazard(col: int, row: int) -> void:
	var h: Area2D = HazardScene.instantiate()
	h.position = Vector2(col * TILE + TILE / 2, row * TILE)
	add_child(h)

func _spawn_player() -> void:
	_player_ref = PlayerScene.instantiate()
	_player_ref.position = Vector2(3 * TILE, (platform_data[0][1] - 2) * TILE) if platform_data.size() > 0 else Vector2(48, 128)
	_player_ref.add_to_group("player")
	_player_ref.died.connect(_on_player_died)
	add_child(_player_ref)

func _spawn_hud() -> void:
	_hud = HUDScene.instantiate()
	add_child(_hud)

func _update_hud() -> void:
	if _hud == null:
		return
	_hud.update_score(GameData.score)
	_hud.update_lives(GameData.lives)
	_hud.update_timer(_time_left)
	_hud.update_level("LVL %d: %s" % [level_number, GameData.get_level_name()])
	_hud.update_collect(_collected, _total_collectibles)

func _physics_process(delta: float) -> void:
	if not _is_running or _paused:
		return

	# Countdown timer
	_time_left -= delta
	if _hud:
		_hud.update_timer(_time_left)
	if _time_left <= 0.0:
		_time_left = 0.0
		_trigger_game_over("Time's up!")

	# Check if player fell off-screen
	if _player_ref and _player_ref.position.y > 300:
		_on_player_died()

	# Pause
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	_paused = !_paused
	get_tree().paused = _paused
	if _paused:
		_pause_menu.show()
	else:
		_pause_menu.hide()

func _on_resume() -> void:
	_paused = false
	get_tree().paused = false
	_pause_menu.hide()

func _on_quit_to_menu() -> void:
	get_tree().paused = false
	GameData.reset_game()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_item_picked_up(points: int, is_boost: bool) -> void:
	_collected += 1
	GameData.add_score(points)
	if _hud:
		_hud.update_score(GameData.score)
		_hud.update_collect(_collected, _total_collectibles)
		if is_boost:
			_hud.show_notification("☕ CAFFEINE BOOST!")
		else:
			_hud.show_notification("+%d" % points)
	if is_boost and _player_ref:
		_player_ref.apply_boost()
	# Open door when all notes collected
	if _collected >= _total_collectibles:
		_open_exit_door()

func _open_exit_door() -> void:
	if _hud:
		_hud.show_notification("EXIT OPEN! Go go go!", 2.5)
	for child in get_children():
		if child is Area2D and child.has_method("open_door"):
			child.open_door()

func _on_door_entered() -> void:
	if not _is_running:
		return
	_is_running = false
	Audio.play_levelup()
	var time_bonus: int = ceili(_time_left) * 5
	GameData.add_score(time_bonus)
	if _hud:
		_hud.show_notification("LEVEL COMPLETE!\n+%d TIME BONUS" % time_bonus, 2.5)
	await get_tree().create_timer(2.5).timeout
	level_complete.emit()
	_go_next_level()

func _go_next_level() -> void:
	if GameData.advance_level():
		get_tree().change_scene_to_file(GameData.get_level_scene())
	else:
		# All levels done — victory!
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _on_player_died() -> void:
	if not _is_running:
		return
	var is_dead := GameData.lose_life()
	if _hud:
		_hud.update_lives(GameData.lives)
	if is_dead:
		_trigger_game_over("Game Over!")
	else:
		# Respawn player with brief post-spawn invincibility
		await get_tree().create_timer(0.8).timeout
		if _player_ref and is_instance_valid(_player_ref):
			_player_ref.position = Vector2(3 * TILE, (platform_data[0][1] - 2) * TILE) if platform_data.size() > 0 else Vector2(48, 128)
			_player_ref.velocity = Vector2.ZERO
			_player_ref._dead = false
			_player_ref._is_invincible = true
			_player_ref._inv_timer = 1.5
			_player_ref._blink_timer = 0.0
			_player_ref.modulate.a = 1.0
		if _hud:
			_hud.show_notification("%d LIVES LEFT" % GameData.lives)

func _trigger_game_over(msg: String) -> void:
	if not _is_running:
		return
	_is_running = false
	Audio.play_gameover()
	if _hud:
		_hud.show_notification(msg, 2.0)
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

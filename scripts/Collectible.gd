extends Area2D
## Collectible — A floating study note or coffee cup the player can pick up.
## notes give points; coffee cups give a speed boost in addition.

signal picked_up(points: int, is_boost: bool)

@export var points: int = 10
@export var is_boost: bool = false  # coffee cup gives speed boost

const COL_NOTE_BODY  := Color(0.95, 0.92, 0.75)
const COL_NOTE_LINE  := Color(0.50, 0.50, 0.80)
const COL_NOTE_RULE  := Color(0.70, 0.70, 0.90)
const COL_CUP_BODY   := Color(0.85, 0.35, 0.10)
const COL_CUP_STEAM  := Color(0.85, 0.85, 0.85)
const COL_CUP_BAND   := Color(0.50, 0.20, 0.05)
const COL_STAR       := Color(1.00, 0.85, 0.10)

var _bob_timer: float = 0.0
var _bob_offset: float = 0.0
var _bob_speed: float  = 2.5
var _bob_amp: float    = 2.5
var _spin: float       = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Vary bob phase per collectible so they don't all sync
	_bob_timer = randf() * TAU

func _process(delta: float) -> void:
	_bob_timer += delta * _bob_speed
	_bob_offset = sinf(_bob_timer) * _bob_amp
	_spin += delta * 1.5
	queue_redraw()

func _draw() -> void:
	if is_boost:
		_draw_coffee()
	else:
		_draw_note()

func _draw_note() -> void:
	var y: float = _bob_offset
	# Paper background
	_px(Vector2(-5.0, -6.0 + y), Vector2(10.0, 12.0), COL_NOTE_BODY)
	# Blue margin line
	_px(Vector2(-2.0, -6.0 + y), Vector2(1.0, 12.0), COL_NOTE_LINE)
	# Ruled lines
	for i in range(3):
		_px(Vector2(-1.0, -3.0 + float(i) * 3.0 + y), Vector2(7.0, 1.0), COL_NOTE_RULE)
	# Gold star top-right
	_px(Vector2(2.0, -6.0 + y), Vector2(2.0, 2.0), COL_STAR)

func _draw_coffee() -> void:
	var y: float = _bob_offset
	# Cup body
	_px(Vector2(-4.0, -4.0 + y), Vector2(8.0, 8.0), COL_CUP_BODY)
	# Sleeve band
	_px(Vector2(-4.0, 0.0 + y), Vector2(8.0, 2.0), COL_CUP_BAND)
	# Lid
	_px(Vector2(-5.0, -6.0 + y), Vector2(10.0, 2.0), Color(0.3, 0.2, 0.1))
	# Steam
	for i in range(3):
		var sx: float = -2.0 + float(i) * 2.0
		var phase: float = _bob_timer + float(i) * 0.8
		var wave: float  = sinf(phase) * 1.5
		_px(Vector2(sx + wave, -8.0 + y - float(i) * 1.5), Vector2(1.0, 2.0), COL_CUP_STEAM)

func _px(pos: Vector2, size: Vector2, col: Color) -> void:
	draw_rect(Rect2(pos, size), col)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		Audio.play_collect()
		picked_up.emit(points, is_boost)
		queue_free()

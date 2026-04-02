extends Area2D
## ExitDoor — The level goal.  Triggers when the player has collected enough
## items and walks into the door.

signal door_entered

var _is_open: bool = false
var _glow_timer: float = 0.0

const COL_FRAME   := Color(0.50, 0.40, 0.20)
const COL_DOOR    := Color(0.35, 0.25, 0.10)
const COL_DOOR_OP := Color(0.10, 0.55, 0.90)
const COL_KNOB    := Color(0.85, 0.75, 0.10)
const COL_GLOW    := Color(0.20, 0.80, 1.00)
const COL_SIGN    := Color(0.90, 0.90, 0.20)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func open_door() -> void:
	_is_open = true

func _process(delta: float) -> void:
	_glow_timer += delta * 3.0
	queue_redraw()

func _draw() -> void:
	# Door frame
	_px(Vector2(-8.0, -24.0), Vector2(16.0, 24.0), COL_FRAME)
	# Door panel
	if _is_open:
		var a: float = absf(sinf(_glow_timer)) * 0.7 + 0.3
		_px(Vector2(-6.0, -22.0), Vector2(12.0, 22.0), Color(COL_DOOR_OP.r, COL_DOOR_OP.g, COL_DOOR_OP.b, a))
		# Shining effect
		var glow := Color(COL_GLOW.r, COL_GLOW.g, COL_GLOW.b, a * 0.6)
		_px(Vector2(-7.0, -24.0), Vector2(14.0, 24.0), glow)
	else:
		_px(Vector2(-6.0, -22.0), Vector2(12.0, 22.0), COL_DOOR)
		# Door knob
		_px(Vector2(2.0, -12.0), Vector2(2.0, 2.0), COL_KNOB)
	# "EXIT" sign above door
	_px(Vector2(-7.0, -28.0), Vector2(14.0, 5.0), COL_SIGN)

func _px(pos: Vector2, size: Vector2, col: Color) -> void:
	draw_rect(Rect2(pos, size), col)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and _is_open:
		door_entered.emit()

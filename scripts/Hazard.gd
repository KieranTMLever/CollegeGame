extends Area2D
## Hazard — A static danger zone (electric outlet / spike strip) that damages
## the player on contact.

const COL_SPIKE := Color(0.75, 0.75, 0.85)
const COL_BASE  := Color(0.45, 0.45, 0.55)
const COL_GLOW  := Color(1.00, 0.90, 0.20)

var _glow_timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_glow_timer += delta * 4.0
	queue_redraw()

func _draw() -> void:
	# Base strip
	_px(Vector2(-8.0, -1.0), Vector2(16.0, 4.0), COL_BASE)
	# Three spikes
	for i in range(3):
		var sx: float = -4.0 + float(i) * 4.0
		# Spike triangle drawn as overlapping rects
		_px(Vector2(sx,        -5.0), Vector2(2.0, 4.0), COL_SPIKE)
		_px(Vector2(sx + 0.5,  -7.0), Vector2(1.0, 2.0), COL_SPIKE)
	# Electrical glow pulse
	var glow_alpha: float = (sinf(_glow_timer) * 0.3 + 0.4)
	var glow_col := Color(COL_GLOW.r, COL_GLOW.g, COL_GLOW.b, glow_alpha)
	_px(Vector2(-8.0, -8.0), Vector2(16.0, 8.0), glow_col)

func _px(pos: Vector2, size: Vector2, col: Color) -> void:
	draw_rect(Rect2(pos, size), col)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage()

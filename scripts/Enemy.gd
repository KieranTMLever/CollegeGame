extends CharacterBody2D
## Enemy — A zombified student that patrols a platform, reversing direction
## at walls and ledge edges.  Harms the player on contact.

const SPEED_NORMAL: float = 35.0
const SPEED_FAST:   float = 60.0
const GRAVITY: float      = 900.0

@export var patrol_speed: float = SPEED_NORMAL
@export var face_right_start: bool = true

var _dir: float = 1.0
var _dead: bool = false
var _frame: int = 0
var _anim_timer: float = 0.0
const ANIM_FPS: float = 5.0

# Pixel colours
const COL_BODY  := Color(0.55, 0.75, 0.40)  # zombie green
const COL_EYE   := Color(0.95, 0.10, 0.10)  # red eyes
const COL_SHIRT := Color(0.30, 0.20, 0.45)
const COL_PANTS := Color(0.20, 0.15, 0.30)
const COL_SHOES := Color(0.10, 0.08, 0.10)

@onready var _wall_ray_l: RayCast2D = $WallLeft
@onready var _wall_ray_r: RayCast2D = $WallRight
@onready var _edge_ray_l: RayCast2D = $EdgeLeft
@onready var _edge_ray_r: RayCast2D = $EdgeRight
@onready var _hitbox: Area2D        = $Hitbox

func _ready() -> void:
	_dir = 1.0 if face_right_start else -1.0
	_hitbox.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if _dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Turn at walls and ledge edges
	var hit_wall: bool = (_dir > 0 and _wall_ray_r.is_colliding()) or \
	                     (_dir < 0 and _wall_ray_l.is_colliding())
	var at_edge: bool  = (_dir > 0 and not _edge_ray_r.is_colliding()) or \
	                     (_dir < 0 and not _edge_ray_l.is_colliding())
	if hit_wall or at_edge:
		_dir = -_dir

	velocity.x = _dir * patrol_speed
	move_and_slide()

	# Animate
	_anim_timer += delta
	if _anim_timer >= 1.0 / ANIM_FPS:
		_anim_timer = 0.0
		_frame = (_frame + 1) % 4
	queue_redraw()

func _draw() -> void:
	var flip: float = _dir  # 1 = right, -1 = left
	var leg_l: float = sinf(float(_frame) * PI * 0.5) * 2.0
	var leg_r: float = -leg_l
	var bob: float   = sinf(float(_frame) * PI * 0.5) * 0.5

	# Body
	_px(Vector2(-3.0, -8.0 + bob), Vector2(6.0, 8.0), COL_SHIRT)
	# Head
	_px(Vector2(-3.0, -16.0 + bob), Vector2(6.0, 7.0), COL_BODY)
	# Hair (messy — two bumps)
	_px(Vector2(-3.0, -18.0 + bob), Vector2(3.0, 3.0), Color(0.1, 0.1, 0.1))
	_px(Vector2(1.0,  -19.0 + bob), Vector2(2.0, 3.0), Color(0.1, 0.1, 0.1))
	# Eyes (both red, slightly off)
	_px(Vector2(flip * -1.0 - 1.0, -14.0 + bob), Vector2(1.0, 1.0), COL_EYE)
	_px(Vector2(flip *  1.0,       -14.0 + bob), Vector2(1.0, 1.0), COL_EYE)
	# Arms (outstretched zombie)
	_px(Vector2(flip * 3.0, -9.0 + bob), Vector2(3.0, 2.0), COL_BODY)
	# Legs
	_px(Vector2(-3.0, 0.0 + leg_l), Vector2(2.0, 5.0), COL_PANTS)
	_px(Vector2( 0.0, 0.0 + leg_r), Vector2(2.0, 5.0), COL_PANTS)
	_px(Vector2(-4.0, 4.0 + leg_l), Vector2(3.0, 2.0), COL_SHOES)
	_px(Vector2( 0.0, 4.0 + leg_r), Vector2(3.0, 2.0), COL_SHOES)

func _px(pos: Vector2, size: Vector2, col: Color) -> void:
	draw_rect(Rect2(pos, size), col)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage()

func die() -> void:
	_dead = true
	queue_free()

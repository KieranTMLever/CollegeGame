extends CharacterBody2D
## Player — Handles movement, jumping, animation tinting, invincibility, and damage.

signal died
signal item_collected(points: int)

const WALK_SPEED: float   = 80.0
const BOOST_SPEED: float  = 130.0
const JUMP_FORCE: float   = -260.0
const GRAVITY: float      = 900.0
const COYOTE_TIME: float  = 0.12   # grace window after walking off edge
const JUMP_BUFFER: float  = 0.1    # buffered jump input window
const INVINCIBLE_TIME: float = 1.8

var speed: float = WALK_SPEED
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false
var _is_invincible: bool = false
var _inv_timer: float = 0.0
var _blink_timer: float = 0.0

# Boost state
var _boost_timer: float = 0.0
const BOOST_DURATION: float = 5.0

# Player palette — colours used in _draw()
const COL_SKIN    := Color(0.95, 0.78, 0.58)
const COL_HAIR    := Color(0.25, 0.18, 0.10)
const COL_SHIRT   := Color(0.20, 0.45, 0.85)
const COL_PANTS   := Color(0.18, 0.18, 0.45)
const COL_SHOES   := Color(0.10, 0.10, 0.12)
const COL_EYE     := Color(0.05, 0.05, 0.15)
const COL_BAG     := Color(0.80, 0.30, 0.10)

# Animation
var _frame: int = 0
var _anim_timer: float = 0.0
const ANIM_FPS: float = 8.0
var _facing_left: bool = false
var _is_jumping: bool = false
var _dead: bool = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if _dead:
		return

	# ── Invincibility blink ──────────────────────────────────────────────────
	if _is_invincible:
		_inv_timer -= delta
		_blink_timer += delta
		modulate.a = 0.25 if fmod(_blink_timer, 0.15) < 0.075 else 1.0
		if _inv_timer <= 0.0:
			_is_invincible = false
			modulate.a = 1.0

	# ── Boost timer ──────────────────────────────────────────────────────────
	if _boost_timer > 0.0:
		_boost_timer -= delta
		if _boost_timer <= 0.0:
			speed = WALK_SPEED

	# ── Gravity ──────────────────────────────────────────────────────────────
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = minf(velocity.y, 600.0)

	# ── Coyote time ──────────────────────────────────────────────────────────
	if _was_on_floor and not is_on_floor():
		_coyote_timer = COYOTE_TIME
	elif is_on_floor():
		_coyote_timer = 0.0
	else:
		_coyote_timer -= delta
	_was_on_floor = is_on_floor()

	# ── Jump buffer ──────────────────────────────────────────────────────────
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER
	else:
		_jump_buffer_timer -= delta

	# ── Jump ─────────────────────────────────────────────────────────────────
	if _jump_buffer_timer > 0.0 and (is_on_floor() or _coyote_timer > 0.0):
		velocity.y = JUMP_FORCE
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_is_jumping = true
		Audio.play_jump()

	# ── Variable jump height (release early → shorter jump) ──────────────────
	if Input.is_action_just_released("jump") and velocity.y < -80.0:
		velocity.y *= 0.5

	# ── Horizontal movement ──────────────────────────────────────────────────
	var dir: float = Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = dir * speed
		_facing_left = (dir < 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 8.0 * delta)

	if is_on_floor():
		_is_jumping = false

	move_and_slide()

	# ── Animation ─────────────────────────────────────────────────────────────
	_anim_timer += delta
	if _anim_timer >= 1.0 / ANIM_FPS:
		_anim_timer = 0.0
		if absf(velocity.x) > 4.0 and is_on_floor():
			_frame = (_frame + 1) % 4
		else:
			_frame = 0
	queue_redraw()

func _draw() -> void:
	# All drawing is done at pixel scale (each "pixel" = 1 unit)
	# Origin is centre of sprite. Sprite is 16×20 px.
	var flip: float = -1.0 if _facing_left else 1.0
	var bob: float = 0.0
	if not _is_jumping and absf(velocity.x) > 4.0:
		bob = sinf(float(_frame) * PI * 0.5) * 0.8

	# Leg walk cycle offsets
	var leg_l_y: float = 0.0
	var leg_r_y: float = 0.0
	if absf(velocity.x) > 4.0 and not _is_jumping:
		leg_l_y = sinf(float(_frame) * PI * 0.5) * 2.0
		leg_r_y = -leg_l_y

	var offset := Vector2(0.0, bob)

	# ── Body ─────────────────────────────────────────────────────────────────
	_px(offset + Vector2(flip * -3.0, -8.0), Vector2(6.0, 8.0), COL_SHIRT)

	# ── Backpack ─────────────────────────────────────────────────────────────
	_px(offset + Vector2(flip * 3.0, -7.0), Vector2(2.0, 5.0), COL_BAG)

	# ── Head ─────────────────────────────────────────────────────────────────
	_px(offset + Vector2(flip * -3.0, -16.0), Vector2(6.0, 7.0), COL_SKIN)
	_px(offset + Vector2(flip * -3.0, -18.0), Vector2(6.0, 3.0), COL_HAIR)
	# Eye
	_px(offset + Vector2(flip * (1.0 if not _facing_left else -2.0), -14.0), Vector2(1.0, 1.0), COL_EYE)

	# ── Arms ─────────────────────────────────────────────────────────────────
	_px(offset + Vector2(flip * -5.0, -8.0), Vector2(2.0, 5.0), COL_SKIN)

	# ── Legs ─────────────────────────────────────────────────────────────────
	_px(offset + Vector2(flip * -3.0, 0.0 + leg_l_y), Vector2(2.0, 5.0), COL_PANTS)
	_px(offset + Vector2(flip * 0.0,  0.0 + leg_r_y), Vector2(2.0, 5.0), COL_PANTS)

	# ── Shoes ─────────────────────────────────────────────────────────────────
	_px(offset + Vector2(flip * -4.0, 4.0 + leg_l_y), Vector2(3.0, 2.0), COL_SHOES)
	_px(offset + Vector2(flip * 0.0,  4.0 + leg_r_y), Vector2(3.0, 2.0), COL_SHOES)

func _px(pos: Vector2, size: Vector2, col: Color) -> void:
	draw_rect(Rect2(pos, size), col)

func take_damage() -> void:
	if _is_invincible or _dead:
		return
	_is_invincible = true
	_inv_timer = INVINCIBLE_TIME
	_blink_timer = 0.0
	Audio.play_hurt()
	died.emit()

func apply_boost() -> void:
	speed = BOOST_SPEED
	_boost_timer = BOOST_DURATION
	Audio.play_powerup()

func kill() -> void:
	_dead = true
	modulate.a = 0.0

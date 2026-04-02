extends CanvasLayer
## HUD — Displays score, lives, timer, level name, and floating notifications.

@onready var _score_label:   Label = $Control/TopBar/ScoreLabel
@onready var _lives_label:   Label = $Control/TopBar/LivesLabel
@onready var _timer_label:   Label = $Control/TopBar/TimerLabel
@onready var _level_label:   Label = $Control/TopBar/LevelLabel
@onready var _notif_label:   Label = $Control/NotifLabel
@onready var _collect_label: Label = $Control/TopBar/CollectLabel

var _notif_timer: float = 0.0
var _notif_duration: float = 1.5

func _process(delta: float) -> void:
	if _notif_timer > 0.0:
		_notif_timer -= delta
		_notif_label.modulate.a = minf(1.0, _notif_timer / 0.4)
		if _notif_timer <= 0.0:
			_notif_label.text = ""

func update_score(score: int) -> void:
	_score_label.text = "SCORE %d" % score

func update_lives(lives: int) -> void:
	var hearts := ""
	for i in range(lives):
		hearts += "♥ "
	_lives_label.text = hearts.strip_edges()

func update_timer(secs: float) -> void:
	var t := ceili(secs)
	_timer_label.text = "TIME %02d" % t
	# Flash red when under 10 seconds
	if t <= 10:
		_timer_label.modulate = Color(1.0, 0.3, 0.3) if fmod(secs, 0.5) < 0.25 else Color.WHITE
	else:
		_timer_label.modulate = Color.WHITE

func update_level(name: String) -> void:
	_level_label.text = name

func update_collect(collected: int, total: int) -> void:
	_collect_label.text = "📓 %d/%d" % [collected, total]

func show_notification(text: String, duration: float = 1.5) -> void:
	_notif_label.text = text
	_notif_label.modulate.a = 1.0
	_notif_timer = duration
	_notif_duration = duration

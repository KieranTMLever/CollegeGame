extends Control
## GameOver — Shown on victory OR defeat.  Displays final score and options.

@onready var _title_label:  Label  = $VBox/TitleLabel
@onready var _score_label:  Label  = $VBox/ScoreLabel
@onready var _best_label:   Label  = $VBox/BestLabel
@onready var _retry_btn:    Button = $VBox/RetryBtn
@onready var _menu_btn:     Button = $VBox/MenuBtn
@onready var _quit_btn:     Button = $VBox/QuitBtn

var _anim_timer: float = 0.0

func _ready() -> void:
	# Were all 3 levels completed?
	var won := GameData.current_level > GameData.LEVEL_SCENES.size()
	_title_label.text = "🎓 YOU GRADUATED! 🎓" if won else "GAME OVER"
	_title_label.modulate = Color(0.4, 1.0, 0.5) if won else Color(1.0, 0.3, 0.3)
	_score_label.text  = "SCORE: %d" % GameData.score
	_best_label.text   = "BEST:  %d" % GameData.high_score
	_retry_btn.pressed.connect(_on_retry)
	_menu_btn.pressed.connect(_on_menu)
	_quit_btn.pressed.connect(_on_quit)

func _process(delta: float) -> void:
	_anim_timer += delta
	_title_label.modulate.v = 0.7 + sinf(_anim_timer * 3.0) * 0.3
	queue_redraw()

func _draw() -> void:
	# Twinkling pixel stars
	for i in range(15):
		var x := fmod(float(i) * 22.1 + _anim_timer * 12.0, 320.0)
		var y := fmod(float(i) * 13.7, 180.0)
		var a := absf(sinf(_anim_timer * 2.5 + float(i))) * 0.7 + 0.2
		draw_rect(Rect2(x, y, 2, 2), Color(1.0, 1.0, 0.6, a))

func _on_retry() -> void:
	Audio.play_menu_select()
	GameData.reset_game()
	get_tree().change_scene_to_file(GameData.get_level_scene())

func _on_menu() -> void:
	Audio.play_menu_back()
	GameData.reset_game()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_quit() -> void:
	Audio.play_menu_back()
	GameData.save_settings()
	get_tree().quit()

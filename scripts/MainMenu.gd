extends Control
## MainMenu — Title screen with Start, Controls, Audio and Quit buttons.

@onready var _start_btn:    Button = $VBox/StartBtn
@onready var _controls_btn: Button = $VBox/ControlsBtn
@onready var _audio_btn:    Button = $VBox/AudioBtn
@onready var _quit_btn:     Button = $VBox/QuitBtn
@onready var _high_label:   Label  = $HighScoreLabel
@onready var _diff_btn:     Button = $VBox/DiffBtn

var _anim_timer: float = 0.0

func _ready() -> void:
	_start_btn.pressed.connect(_on_start)
	_controls_btn.pressed.connect(_on_controls)
	_audio_btn.pressed.connect(_on_audio)
	_quit_btn.pressed.connect(_on_quit)
	_diff_btn.pressed.connect(_on_difficulty)
	_update_high_score()
	_update_diff_label()
	# Ensure tree is un-paused in case player quit from pause menu
	get_tree().paused = false

func _process(delta: float) -> void:
	_anim_timer += delta
	queue_redraw()

func _draw() -> void:
	# Draw scrolling pixel-art background stars
	for i in range(20):
		var x: float = fmod(float(i) * 17.3 + _anim_timer * (5.0 + float(i) * 0.4), 320.0)
		var y: float = float(i) * 9.7
		y = fmod(y, 180.0)
		var bright: float = absf(sinf(_anim_timer * 1.2 + float(i))) * 0.6 + 0.3
		draw_rect(Rect2(x, y, 1, 1), Color(bright, bright, bright + 0.1))

func _update_high_score() -> void:
	_high_label.text = "BEST: %d" % GameData.high_score

func _update_diff_label() -> void:
	_diff_btn.text = "DIFFICULTY: %s" % ("HARD" if GameData.difficulty == 2 else "NORMAL")

func _on_start() -> void:
	Audio.play_menu_select()
	GameData.reset_game()
	get_tree().change_scene_to_file(GameData.get_level_scene())

func _on_controls() -> void:
	Audio.play_menu_select()
	get_tree().change_scene_to_file("res://scenes/ControlsMenu.tscn")

func _on_audio() -> void:
	Audio.play_menu_select()
	get_tree().change_scene_to_file("res://scenes/AudioMenu.tscn")

func _on_difficulty() -> void:
	Audio.play_menu_select()
	GameData.difficulty = 2 if GameData.difficulty == 1 else 1
	_update_diff_label()

func _on_quit() -> void:
	Audio.play_menu_back()
	get_tree().quit()

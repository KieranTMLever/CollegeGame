extends Control
## PauseMenu — Shown when the player presses Escape in-game.

signal resume_requested
signal quit_requested

@onready var _resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var _quit_btn:   Button = $Panel/VBox/QuitBtn

func _ready() -> void:
	_resume_btn.pressed.connect(_on_resume)
	_quit_btn.pressed.connect(_on_quit)

func _on_resume() -> void:
	Audio.play_menu_back()
	resume_requested.emit()

func _on_quit() -> void:
	Audio.play_menu_back()
	quit_requested.emit()

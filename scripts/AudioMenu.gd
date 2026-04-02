extends Control
## AudioMenu — Three sliders for master, music, and SFX volume.

@onready var _master_slider: HSlider = $VBox/MasterRow/MasterSlider
@onready var _music_slider:  HSlider = $VBox/MusicRow/MusicSlider
@onready var _sfx_slider:    HSlider = $VBox/SFXRow/SFXSlider
@onready var _master_val:    Label   = $VBox/MasterRow/MasterVal
@onready var _music_val:     Label   = $VBox/MusicRow/MusicVal
@onready var _sfx_val:       Label   = $VBox/SFXRow/SFXVal
@onready var _back_btn:      Button  = $VBox/BackBtn

func _ready() -> void:
	_master_slider.value = GameData.master_volume
	_music_slider.value  = GameData.music_volume
	_sfx_slider.value    = GameData.sfx_volume
	_update_labels()

	_master_slider.value_changed.connect(_on_master_changed)
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_back_btn.pressed.connect(_on_back)

func _update_labels() -> void:
	_master_val.text = "%d%%" % roundi(GameData.master_volume * 100.0)
	_music_val.text  = "%d%%" % roundi(GameData.music_volume  * 100.0)
	_sfx_val.text    = "%d%%" % roundi(GameData.sfx_volume    * 100.0)

func _on_master_changed(v: float) -> void:
	GameData.master_volume = v
	GameData.apply_volumes()
	_update_labels()

func _on_music_changed(v: float) -> void:
	GameData.music_volume = v
	GameData.apply_volumes()
	_update_labels()

func _on_sfx_changed(v: float) -> void:
	GameData.sfx_volume = v
	GameData.apply_volumes()
	_update_labels()
	Audio.play_menu_select()

func _on_back() -> void:
	GameData.save_settings()
	Audio.play_menu_back()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

extends Control
## ControlsMenu — Lets the player rebind each action by clicking a button
## and pressing the desired key.

@onready var _back_btn:     Button = $VBox/BackBtn
@onready var _rows_container: VBoxContainer = $VBox/RowsContainer
@onready var _listening_label: Label = $ListeningLabel

var _listening_for: String = ""
var _row_buttons: Dictionary = {}

func _ready() -> void:
	_back_btn.pressed.connect(_on_back)
	_listening_label.hide()
	_build_rows()

func _build_rows() -> void:
	for child in _rows_container.get_children():
		child.queue_free()

	for action in GameData.DEFAULT_BINDINGS:
		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_theme_constant_override("separation", 8)

		var label := Label.new()
		label.text = GameData.ACTION_LABELS[action]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_color_override("font_color", Color(0.85, 0.85, 1.0))
		hbox.add_child(label)

		var btn := Button.new()
		btn.text = GameData.get_action_key_name(action)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_bind_pressed.bind(action))
		hbox.add_child(btn)

		_row_buttons[action] = btn
		_rows_container.add_child(hbox)

func _on_bind_pressed(action: String) -> void:
	Audio.play_menu_select()
	_listening_for = action
	_listening_label.text = "Press a key for  \"%s\"..." % GameData.ACTION_LABELS[action]
	_listening_label.show()
	# Dim all buttons
	for a in _row_buttons:
		_row_buttons[a].disabled = true
	_back_btn.disabled = true

func _input(event: InputEvent) -> void:
	if _listening_for == "":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: int = event.physical_keycode
		GameData.remap_action(_listening_for, kc)
		_row_buttons[_listening_for].text = GameData.get_action_key_name(_listening_for)
		_listening_for = ""
		_listening_label.hide()
		# Re-enable buttons
		for a in _row_buttons:
			_row_buttons[a].disabled = false
		_back_btn.disabled = false
		get_viewport().set_input_as_handled()

func _on_back() -> void:
	Audio.play_menu_back()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

extends Control

signal digit_pressed(value: String)
signal enter_pressed
signal reset_pressed
signal closed

@onready var _panel: Control = $CenterContainer/Panel
@onready var _display_label: Label = %DisplayLabel
@onready var _feedback_label: Label = %FeedbackLabel
@onready var _digits: GridContainer = %Digits
@onready var _zero_button: Button = %ZeroButton
@onready var _reset_button: Button = %ResetButton
@onready var _enter_button: Button = %EnterButton
@onready var _close_button: Button = %CloseButton

var _max_digits: int = 4
var _previous_mouse_mode := Input.MOUSE_MODE_CAPTURED

# this lets the player controller know the UI is open
var ui_active := false

# M: reference to player so we can lock controls when keypad is open
var _player: Node = null


func _ready() -> void:
	visible = false
	_wire_digit_buttons()
	_reset_button.pressed.connect(_on_reset_button)
	_enter_button.pressed.connect(_on_enter_button)
	_close_button.pressed.connect(_on_close_button)

	# M: grab the player from the "player" group
	_player = get_tree().get_first_node_in_group("player")


func show_panel(max_digits: int, current_input: String = "") -> void:
	_previous_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	ui_active = true

	# M: tell player script to lock movement/camera
	if _player and _player.has_method("set_ui_locked"):
		_player.set_ui_locked(true)

	_max_digits = max(max_digits, 1)
	visible = true
	update_display(current_input)
	set_feedback("Enter the code to unlock.")


func hide_panel() -> void:
	visible = false
	Input.set_mouse_mode(_previous_mouse_mode)

	ui_active = false

	# M: unlock player controls when keypad closes
	if _player and _player.has_method("set_ui_locked"):
		_player.set_ui_locked(false)


func update_display(current_input: String) -> void:
	var clamped := current_input.substr(0, _max_digits)
	var dots := "·".repeat(max(0, _max_digits - clamped.length()))
	_display_label.text = "PIN: %s" % (clamped + dots)


func set_feedback(message: String) -> void:
	_feedback_label.text = message


func _wire_digit_buttons() -> void:
	for child in _digits.get_children():
		if child is Button:
			child.pressed.connect(_on_digit_button.bind(child.text))

	if _zero_button and not _zero_button.pressed.is_connected(_on_digit_button):
		_zero_button.pressed.connect(_on_digit_button.bind(_zero_button.text))


func _on_digit_button(value: String) -> void:
	digit_pressed.emit(value)


func _on_reset_button() -> void:
	reset_pressed.emit()


func _on_enter_button() -> void:
	enter_pressed.emit()


func _on_close_button() -> void:
	hide_panel()
	closed.emit()

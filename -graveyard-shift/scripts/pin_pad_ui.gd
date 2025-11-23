extends Control

signal digit_pressed(value: String)
signal enter_pressed
signal reset_pressed
signal closed

@export var prompt_text: String = "Keypad Access"

@onready var _display_label: Label = %DisplayLabel
@onready var _feedback_label: Label = %FeedbackLabel
@onready var _title_label: Label = %TitleLabel
@onready var _digit_container: GridContainer = %Digits
@onready var _zero_button: Button = %ZeroButton
@onready var _reset_button: Button = %ResetButton
@onready var _enter_button: Button = %EnterButton
@onready var _close_button: Button = %CloseButton

var _max_digits := 4

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_title_label.text = prompt_text
	_wire_buttons()
	_update_display("")

func show_panel(max_digits: int, current_input: String) -> void:
	_max_digits = max(1, max_digits)
	_title_label.text = prompt_text
	_feedback_label.text = "Enter the code to unlock."
	_update_display(current_input)

	visible = true
	grab_focus()

	# 🔓 Unlock mouse when UI opens
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_panel() -> void:
	visible = false
	closed.emit()

	# 🔒 Lock mouse back into FPS mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_display(input_text: String) -> void:
	_update_display(input_text)

func set_feedback(text: String) -> void:
	_feedback_label.text = text

func _update_display(input_text: String) -> void:
	var padded := input_text.lpad(_max_digits, "·")
	_display_label.text = "PIN: %s" % padded

func _wire_buttons() -> void:
	if _digit_container:
		for child in _digit_container.get_children():
			if child is Button:
				child.pressed.connect(_on_digit_button_pressed.bind(child.text))

	if _zero_button:
		_zero_button.pressed.connect(_on_digit_button_pressed.bind("0"))

	if _reset_button:
		_reset_button.pressed.connect(_on_reset_button_pressed)

	if _enter_button:
		_enter_button.pressed.connect(_on_enter_button_pressed)

	if _close_button:
		_close_button.pressed.connect(_on_close_button_pressed)

func _on_digit_button_pressed(value: String) -> void:
	digit_pressed.emit(value)

func _on_reset_button_pressed() -> void:
	reset_pressed.emit()

func _on_enter_button_pressed() -> void:
	enter_pressed.emit()

func _on_close_button_pressed() -> void:
	hide_panel()

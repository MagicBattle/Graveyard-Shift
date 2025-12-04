extends Node3D

@export var open_angle_degrees: float = 90.0
@export_range(0.1, 5.0, 0.05) var open_time: float = 0.6
@export var close_delay: float = 1.0
@export var auto_close: bool = false
@export var locked: bool = false
@export var uses_pin_pad: bool = false
@export var pin_code: String = "1234"
@export_range(1, 9, 1) var max_pin_digits: int = 4
@export var pin_pad_scene: PackedScene = preload("res://scenes/pin_pad_ui.tscn")
@export var player_group: String = "player"
@export var interact_action: StringName = &"door"

# --- GAME FLOW / PHASE LOGIC ---
@export var is_ceo_door: bool = false
@export var is_death_room_entry: bool = false
@export var is_death_room_exit: bool = false
@export var death_room_id: String = ""
@export var death_room_phase: GameManager.Phase = GameManager.Phase.OFFICE

@onready var pivot: Node3D = $"Door Windowed2"
@onready var area: Area3D = $InteractArea

@onready var open_sound: AudioStreamPlayer3D = $OpenSound
@onready var close_sound: AudioStreamPlayer3D = $CloseSound

@export var is_exit_tutorial_door: bool = false


var _is_open: bool = false
var _bodies_in_area: int = 0
var _closed_rotation: Vector3
var _open_rotation: Vector3
var _tween: Tween
var _close_timer: SceneTreeTimer
var _close_callable := Callable(self, "_on_close_timeout")
var _pin_pad_ui: Control
var _pin_input: String = ""
var _pin_pad_visible: bool = false
var _player_body: CharacterBody3D = null

var tutorial_locked: bool = false

func set_tutorial_locked(value: bool) -> void:
	tutorial_locked = value



func _ready() -> void:
	_closed_rotation = pivot.rotation_degrees
	_open_rotation = _closed_rotation + Vector3(0.0, open_angle_degrees, 0.0)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	set_process(false)

func _can_player_use_this_door_now() -> bool:
	var phase := GameManager.get_phase()
	if tutorial_locked:
		return false

	# CEO DOOR: in tutorial, must have boss file AND have discovered the code
	if is_ceo_door:
		if not _player_has_boss_file():
			return false
		if phase == GameManager.Phase.TUTORIAL and not TutorialManager.can_use_ceo_door():
			return false

	# EXIT TUTORIAL DOOR: in tutorial, must have watched TV / learned code
	if is_exit_tutorial_door:
		if phase == GameManager.Phase.TUTORIAL and not TutorialManager.can_use_exit_door():
			return false

	# 1) TUTORIAL RULE: during tutorial, only doors that are part of it react
	if phase == GameManager.Phase.TUTORIAL:
		if not is_ceo_door and not is_exit_tutorial_door:
			return false

	# 2) DEATH ROOM ENTRY RULE:
	if is_death_room_entry and death_room_id != "":
		if not GameManager.can_unlock_room(death_room_id):
			return false

	# 3) DEATH ROOM EXIT RULE:
	if is_death_room_exit and death_room_id != "":
		if phase == death_room_phase and not GameManager.is_room_completed(death_room_id):
			return false

	return true





func _on_body_entered(body: Node) -> void:
	if not _is_valid_body(body):
		return
	_bodies_in_area += 1
	_cancel_close_timer()
	set_process(true)
	
	if body is CharacterBody3D:
		_player_body = body as CharacterBody3D  # 🔹 remember player

func _on_body_exited(body: Node) -> void:
		if not _is_valid_body(body):
				return
		_bodies_in_area = max(0, _bodies_in_area - 1)
		
		if body == _player_body:
			_player_body = null
		
		if _bodies_in_area == 0:
				set_process(false)
				_hide_pin_pad()
				if auto_close:
						_schedule_close()

func _player_has_boss_file() -> bool:
	if _player_body == null:
		return false
	if _player_body.has_method("has_boss_file"):
		return _player_body.has_boss_file()
	return false


func _is_valid_body(body: Node) -> bool:
		if body == null:
				return false
		if player_group.is_empty():
				return body is CharacterBody3D
		return body.is_in_group(player_group)


func _ensure_pin_pad_ui() -> Control:
		if not uses_pin_pad:
				return null

		if _pin_pad_ui == null and pin_pad_scene != null:
				_pin_pad_ui = pin_pad_scene.instantiate() as Control
				get_tree().root.add_child(_pin_pad_ui)
				_wire_pin_pad_signals()
				_pin_pad_ui.visible = false

		return _pin_pad_ui


func _wire_pin_pad_signals() -> void:
		if _pin_pad_ui == null:
				return

		if not _pin_pad_ui.is_connected("digit_pressed", Callable(self, "_on_pin_digit")):
				_pin_pad_ui.connect("digit_pressed", Callable(self, "_on_pin_digit"))

		if not _pin_pad_ui.is_connected("enter_pressed", Callable(self, "_on_pin_enter")):
				_pin_pad_ui.connect("enter_pressed", Callable(self, "_on_pin_enter"))

		if not _pin_pad_ui.is_connected("reset_pressed", Callable(self, "_on_pin_reset")):
				_pin_pad_ui.connect("reset_pressed", Callable(self, "_on_pin_reset"))

		if not _pin_pad_ui.is_connected("closed", Callable(self, "_on_pin_closed")):
				_pin_pad_ui.connect("closed", Callable(self, "_on_pin_closed"))


func _show_pin_pad() -> void:
		var ui := _ensure_pin_pad_ui()
		if ui == null:
				return

		_pin_input = ""
		_pin_pad_visible = true
		ui.call("show_panel", max_pin_digits, _pin_input)
		ui.call("set_feedback", "Enter the code to unlock.")


func _hide_pin_pad() -> void:
		if _pin_pad_ui == null:
				return
		_pin_pad_visible = false
		_pin_input = ""
		_pin_pad_ui.call("hide_panel")


func _on_pin_digit(value: String) -> void:
		if not _pin_pad_visible:
				return
		if _pin_input.length() >= max_pin_digits:
				return
		_pin_input += value
		_pin_pad_ui.call("update_display", _pin_input)


func _on_pin_reset() -> void:
		if not _pin_pad_visible:
				return
		_pin_input = ""
		_pin_pad_ui.call("update_display", _pin_input)
		_pin_pad_ui.call("set_feedback", "Enter the code to unlock.")


func _on_pin_enter() -> void:
		if not _pin_pad_visible:
				return
		if _pin_input == pin_code:
				_pin_pad_ui.call("set_feedback", "Access granted.")
				_hide_pin_pad()
				unlock_and_open()
				
				if is_ceo_door:
					TutorialManager.on_ceo_door_unlocked()
				
				if is_exit_tutorial_door:
					GameManager.mark_room_completed("tutorial")
					GameManager.set_phase(GameManager.Phase.OFFICE)
					print("Tutorial completed – Office phase unlocked!")
				return

		_pin_pad_ui.call("set_feedback", "Incorrect code. Try again.")
		_pin_input = ""
		_pin_pad_ui.call("update_display", _pin_input)


func _on_pin_closed() -> void:
		_pin_pad_visible = false
		_pin_input = ""

# changed the name to get rid of the error
func _set_open(should_open: bool) -> void:
	if _is_open == should_open:
		return
	_is_open = should_open

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	var target := _open_rotation if should_open else _closed_rotation
	var ease_type := Tween.EASE_OUT if should_open else Tween.EASE_IN

	_tween.tween_property(pivot, "rotation_degrees", target, open_time) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(ease_type)

	# Play sound
	if should_open and open_sound:
		open_sound.play()
	elif not should_open and close_sound:
		close_sound.play()
	NoiseManager.emit_signal("noise_emitted", global_position, 8)


func open() -> void:
	if locked:
		return
	_set_open(true)


func close() -> void:
	_set_open(false)


func unlock_and_open() -> void:
	locked = false
	open()


func lock() -> void:
	locked = true
	close()


func _schedule_close() -> void:
	_cancel_close_timer()
	_close_timer = get_tree().create_timer(close_delay)
	_close_timer.timeout.connect(_close_callable)


func _cancel_close_timer() -> void:
	if _close_timer == null:
		return
	if _close_timer.timeout.is_connected(_close_callable):
		_close_timer.timeout.disconnect(_close_callable)
	_close_timer = null


func _on_close_timeout() -> void:
	_close_timer = null
	_set_open(false)


func _process(_delta: float) -> void:
	if _bodies_in_area <= 0:
		return
	if interact_action.is_empty():
		return
	if not InputMap.has_action(interact_action):
		return

	if Input.is_action_just_pressed(interact_action):
		_cancel_close_timer()

		# 🔹 NEW: Check game/phase rules before anything else
		if not _can_player_use_this_door_now():
			return

		if locked and uses_pin_pad:
			_show_pin_pad()
			return

		if locked:
			return

		_set_open(not _is_open)
	
	if _close_timer == null:
		NoiseManager.emit_signal("door_change")

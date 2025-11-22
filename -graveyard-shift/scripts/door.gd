extends Node3D

@export var open_angle_degrees: float = 90.0
@export_range(0.1, 5.0, 0.05) var open_time: float = 0.6
@export var interact_action: StringName = &"door"
@export var player_group: String = "player"

@onready var pivot: Node3D = $"Door Windowed2"
@onready var area: Area3D = $"Door Windowed2/InteractArea"


@onready var open_sound: AudioStreamPlayer3D = $OpenSound
@onready var close_sound: AudioStreamPlayer3D = $CloseSound

var _is_open: bool = false
var _bodies_in_area: int = 0
var _closed_rotation: Vector3
var _open_rotation: Vector3
var _tween: Tween

func _ready() -> void:
	_closed_rotation = pivot.rotation_degrees
	_open_rotation = _closed_rotation + Vector3(0.0, open_angle_degrees, 0.0)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	set_process(false)

func _on_body_entered(body: Node) -> void:
	if not _is_valid_body(body):
		return
	_bodies_in_area += 1
	set_process(true)

func _on_body_exited(body: Node) -> void:
	if not _is_valid_body(body):
		return
	_bodies_in_area = max(0, _bodies_in_area - 1)
	if _bodies_in_area == 0:
		set_process(false)

func _is_valid_body(body: Node) -> bool:
	if body == null:
		return false
	if player_group.is_empty():
		return body is CharacterBody3D
	return body.is_in_group(player_group)

func _toggle_open() -> void:
	_is_open = not _is_open
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()

	var target = _open_rotation if _is_open else _closed_rotation
	var ease_type = Tween.EASE_OUT if _is_open else Tween.EASE_IN

	_tween.tween_property(pivot, "rotation_degrees", target, open_time).set_trans(Tween.TRANS_SINE).set_ease(ease_type)

	if _is_open and open_sound:
		open_sound.play()
	elif not _is_open and close_sound:
		close_sound.play()

func _process(_delta: float) -> void:
	if _bodies_in_area <= 0:
		return
	if interact_action.is_empty():
		return
	if not InputMap.has_action(interact_action):
		return
	if Input.is_action_just_pressed(interact_action):
		_toggle_open()

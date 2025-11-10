extends Node3D

@export var open_angle_degrees: float = 90.0
@export_range(0.1, 5.0, 0.05) var open_time: float = 0.6
@export var close_delay: float = 1.0
@export var auto_close: bool = true
@export var player_group: String = "player"

@onready var pivot: Node3D = $"Door Windowed2"
@onready var area: Area3D = $InteractArea

@onready var open_sound: AudioStreamPlayer3D = $OpenSound
@onready var close_sound: AudioStreamPlayer3D = $CloseSound


var _is_open: bool = false
var _bodies_in_area: int = 0
var _closed_rotation: Vector3
var _open_rotation: Vector3
var _tween: Tween
var _close_timer: SceneTreeTimer
var _close_callable := Callable(self, "_on_close_timeout")

func _ready() -> void:
		_closed_rotation = pivot.rotation_degrees
		_open_rotation = _closed_rotation + Vector3(0.0, open_angle_degrees, 0.0)
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
		if not _is_valid_body(body):
				return
		_bodies_in_area += 1
		_cancel_close_timer()
		if _bodies_in_area == 1:
				_set_open(true)

func _on_body_exited(body: Node) -> void:
		if not _is_valid_body(body):
				return
		_bodies_in_area = max(0, _bodies_in_area - 1)
		if _bodies_in_area == 0 and auto_close:
				_schedule_close()

func _is_valid_body(body: Node) -> bool:
		if body == null:
				return false
		if player_group.is_empty():
				return body is CharacterBody3D
		return body.is_in_group(player_group)

func _set_open(open: bool) -> void:
	if _is_open == open:
		return
	_is_open = open
	
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	var target := _open_rotation if open else _closed_rotation
	var ease_type := Tween.EASE_OUT if open else Tween.EASE_IN
	_tween.tween_property(pivot, "rotation_degrees", target, open_time).set_trans(Tween.TRANS_SINE).set_ease(ease_type)

	# Play sound
	if open and open_sound:
		open_sound.play()
	elif not open and close_sound:
		close_sound.play()



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
		
		

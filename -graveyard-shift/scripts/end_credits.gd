extends Node3D

@onready var video_player := $VideoStreamPlayer
@onready var camera := $Camera3D
@onready var world := $".."
@onready var env = world.environment
var begin_moving : bool = false
var no_repeat : bool = false


func _process(delta):
	if not no_repeat:
		_final_cutscene()
		
	if begin_moving:
		camera.global_position.x = lerp(camera.global_position.x, -5.0, 0.09 * delta)


func _final_cutscene():
	await get_tree().create_timer(3.0, false).timeout
	await _fade_in()
	no_repeat = true
	if not begin_moving:
		await get_tree().create_timer(3.0, false).timeout
	begin_moving = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	begin_moving = false
	#Transition to Other Scene
	GameManager._change_scene("res://scenes/testcredits.tscn")
	

func _fade_in():
	var fade = get_tree().create_tween()
	fade.tween_property(env, "adjustment_brightness", 1, 5.0)

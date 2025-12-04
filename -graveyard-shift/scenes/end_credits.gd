extends Node3D

@onready var video_player := $VideoStreamPlayer
@onready var camera := $Camera3D

var begin_moving : bool = false
var no_repeat : bool = false


func _process(delta):
	if not no_repeat:
		_final_cutscene()
		
	if begin_moving:
		camera.global_position.x = lerp(camera.global_position.x, -5.0, 0.2 * delta)


func _final_cutscene():
	no_repeat = true
	if not begin_moving:
		await get_tree().create_timer(2.0).timeout
	begin_moving = true
	
	
#func _on_change_scene_trigger_body_entered(body: Node3D) -> void:
	#if body is Camera3D:
		#begin_moving = false
		#video_player.play()
		

func _on_video_stream_player_finished() -> void:
	get_tree().quit()


func _on_area_3d_body_entered(body: Node3D) -> void:
	begin_moving = false
	video_player.play()
	get_tree().paused = true
	video_player.process_mode = Node.PROCESS_MODE_ALWAYS

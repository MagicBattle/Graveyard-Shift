extends Node3D


func _on_change_scene_trigger_body_entered(body: Node3D) -> void:
	if body is Camera3D:
		#Change to Video
		pass

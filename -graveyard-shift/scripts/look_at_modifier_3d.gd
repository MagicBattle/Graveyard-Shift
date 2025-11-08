extends LookAtModifier3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	target_node = body.get_path()
	active = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	target_node = ""
	active = false

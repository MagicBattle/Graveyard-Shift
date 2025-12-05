extends Node3D

func interact() -> void:
	print("Arcade interacted")
	var player := get_tree().get_first_node_in_group("player")
	if player:
		Global.store_player_transform(player)
	Global.go_to_arcade()


func _on_maze_trigger_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

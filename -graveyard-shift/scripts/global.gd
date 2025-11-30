extends Node

const WORLD_SCENE_PATH  := "res://scenes/main.tscn"                # 3D world
const ARCADE_SCENE_PATH := "res://2d/scenes/main_menu.tscn"        # 2D menu (fix this path)

var return_position: Vector3
var return_rotation_y: float
var has_return_position: bool = false


# keep original position
func store_player_transform(player: Node3D) -> void:
	return_position = player.global_position
	return_rotation_y = player.rotation.y
	has_return_position = true
	print("Saved player pos: ", return_position)


func go_to_arcade() -> void:
	print("Going to arcade scene…")
	get_tree().change_scene_to_file(ARCADE_SCENE_PATH)


func return_to_world() -> void:
	print("Returning to world…")
	var tree := get_tree()
	tree.change_scene_to_file(WORLD_SCENE_PATH)

	# wait one frame so the world scene is actually loaded
	await tree.process_frame

	if not has_return_position:
		print("No saved position, skipping restore")
		return

	var player := tree.get_first_node_in_group("player")
	if player:
		player.global_position = return_position
		player.rotation.y = return_rotation_y
		print("Restored player pos: ", return_position)
	else:
		print("Player not found in group 'player'")

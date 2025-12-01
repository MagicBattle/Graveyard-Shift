extends Node

const WORLD_SCENE_PATH := "res://scenes/main.tscn"
const ARCADE_SCENE_PATH := "res://2d/scenes/main_menu.tscn"

var return_position: Vector3
var return_rotation_y: float
var has_return_position: bool = false

func store_player_transform(player: Node3D) -> void:
	return_position = player.global_position
	return_rotation_y = player.rotation.y
	has_return_position = true


func go_to_arcade() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(ARCADE_SCENE_PATH)


func return_to_world() -> void:
	print("Returning to world…")
	get_tree().paused = false
	get_tree().change_scene_to_file(WORLD_SCENE_PATH)

	GameManager.force_playing_state_after_return()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

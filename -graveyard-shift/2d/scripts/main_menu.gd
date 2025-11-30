extends Control

const WORLD_2D_SCENE := "res://2d/world.tscn"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(WORLD_2D_SCENE)

func _on_quit_pressed() -> void:
	Global.return_to_world()

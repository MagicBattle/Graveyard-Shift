extends Control

const WORLD_2D_SCENE := "res://2d/scenes/world.tscn"


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(WORLD_2D_SCENE)


func _on_button_2_pressed() -> void:
	Global.return_to_world()

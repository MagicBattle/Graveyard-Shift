extends Control

const WORLD_2D_SCENE := "res://2d/scenes/world.tscn"


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(WORLD_2D_SCENE)
	GameManager.set_phase(GameManager.Phase.TWOD_GAME)

func _on_button_2_pressed() -> void:
	Global.return_to_world()
	GameManager.set_phase(GameManager.Phase.OFFICE)

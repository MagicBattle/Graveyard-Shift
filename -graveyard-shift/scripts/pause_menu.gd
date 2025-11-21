extends Control

func _on_resume_pressed() -> void:
	GameManager.resume_game()


func _on_main_menu_pressed() -> void:
	GameManager.return_to_menu()

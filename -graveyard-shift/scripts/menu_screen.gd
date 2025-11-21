extends Control

@onready var menu_music = $MenuMusic

func _ready() -> void:
	# Music will start automatically since Autoplay = true
	pass

func _on_play_game_pressed() -> void:
	menu_music.stop()  # Stop background music when game starts
	GameManager.start_game()

func _on_exit_pressed() -> void:
	get_tree().quit()

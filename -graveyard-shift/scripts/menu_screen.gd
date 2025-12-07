extends Node3D

@onready var menu_music = $MenuMusic
@onready var click_sound = $ClickSound

func _ready() -> void:
	# Music will start automatically since Autoplay = true
	pass

func _play_click() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

func _on_play_game_pressed() -> void:
	_play_click()
	menu_music.stop()  # Stop background music when game starts
	GameManager.start_game()

func _on_exit_pressed() -> void:
	_play_click()
	get_tree().quit()

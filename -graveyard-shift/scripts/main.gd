extends Node3D

@onready var pause_menu = $UI/PauseMenu

var paused := false


func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause():
	paused = not paused
	
	get_tree().paused = paused
	pause_menu.visible = paused

	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

extends Node3D

@onready var pause_menu = $UI/PauseMenu

var paused := false

func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	
	_on_state_changed(GameManager.get_state(), GameManager.get_state())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var state: GameManager.State = GameManager.get_state()
		
		if state == GameManager.State.PLAYING:
			GameManager.pause_game()
			
		
func _on_state_changed(prev: GameManager.State, next: GameManager.State) -> void:
	var is_paused := (next == GameManager.State.PAUSED)
	
	pause_menu.visible = is_paused
	
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif next == GameManager.State.PLAYING:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

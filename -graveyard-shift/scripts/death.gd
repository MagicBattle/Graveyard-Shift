extends Node3D


@onready var anim: AnimationPlayer = $Camera3D/CanvasLayer/AnimationPlayer
@onready var death_screen_ui = $Camera3D/CanvasLayer/DeathScreen
@onready var audio_player = $Camera3D/CanvasLayer/AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	death_screen_ui.process_mode = Node.PROCESS_MODE_ALWAYS

	death_screen_ui.visible = false
	
	anim.play("blur")
	audio_player.play()
	anim.animation_finished.connect(_on_animation_end)


func _on_animation_end(anim_name: String) -> void:
	if anim_name == "blur":
		audio_player.stop()
		death_screen_ui.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_continue_pressed() -> void:
	GameManager.start_game()  # REPLACE WITH LOAD CHECKPOINT


func _on_main_menu_pressed() -> void:
	GameManager.return_to_menu()

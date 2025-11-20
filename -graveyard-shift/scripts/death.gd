extends Node3D

@onready var anim: AnimationPlayer = $Camera3D/CanvasLayer/AnimationPlayer
@onready var death_screen_ui = $Camera3D/CanvasLayer/DeathScreen


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim.process_mode = Node.PROCESS_MODE_ALWAYS
	death_screen_ui.process_mode = Node.PROCESS_MODE_ALWAYS

	death_screen_ui.visible = false
	
	anim.play("blur")
	anim.animation_finished.connect(_on_animation_end)
	

func _on_animation_end(anim_name: String) -> void:
	if anim_name == "blur":
		death_screen_ui.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		anim.play("fade_in")


func _on_continue_pressed() -> void:
	GameManager.start_game()  # REPLACE WITH LOAD CHECKPOINT


func _on_main_menu_pressed() -> void:
	GameManager.return_to_menu()

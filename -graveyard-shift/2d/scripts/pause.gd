extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

var is_open: bool = false

func _ready() -> void:
	visible = false
	get_tree().paused = false
	is_open = false
	anim.play("RESET")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		print("ESC pressed, paused? ", get_tree().paused)
		if is_open:
			resume()
		else:
			pause()


func pause() -> void:
	is_open = true
	visible = true
	get_tree().paused = true
	anim.play("blur")


func resume() -> void:
	is_open = false
	get_tree().paused = false
	anim.play_backwards("blur")
	await anim.animation_finished
	visible = false


func _on_resume_pressed() -> void:
	resume()


func _on_quit_pressed() -> void:
	Global.return_to_world()
	GameManager.set_phase(GameManager.Phase.OFFICE)

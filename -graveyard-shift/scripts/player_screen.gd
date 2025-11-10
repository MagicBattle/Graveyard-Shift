extends Control


@onready var dialogue_label = $DialogueLabel
@onready var anim = $DialogueLabel/AnimationPlayer

var showing_dialogue := false

func show_dialogue(text: String, duration : float) -> void:
	# Prevent dialogue overlap
	if showing_dialogue:
		anim.stop()
		dialogue_label.modulate.a = 0
		dialogue_label.visible = false

	showing_dialogue = true
	dialogue_label.text = text
	dialogue_label.visible = true

	anim.play("fade_in")
	await anim.animation_finished
	
	await get_tree().create_timer(duration).timeout

	anim.play("fade_out")
	await anim.animation_finished

	dialogue_label.visible = false
	showing_dialogue = false

extends Control


@onready var dialogue_label = $DialogueLabel
@onready var anim = $DialogueLabel/AnimationPlayer

const TYPEWRITER_TIME_PER_CHAR := 0.035
const TYPEWRITER_MIN_DURATION := 0.45
const TYPEWRITER_MAX_DURATION := 1.35
const POST_REVEAL_SCALE := Vector2(1.03, 1.03)
const POST_REVEAL_DURATION := 0.35

var showing_dialogue := false
var typewriter_tween: Tween

func show_dialogue(text: String, duration : float) -> void:
	# Prevent dialogue overlap
	if showing_dialogue:
		anim.stop()
		if typewriter_tween:
			typewriter_tween.kill()
		dialogue_label.modulate.a = 0
		dialogue_label.visible = false

	showing_dialogue = true
	dialogue_label.text = text
	dialogue_label.visible = true
	dialogue_label.visible_characters = 0

	anim.play("fade_in")

	var typewriter_duration: float = clamp(
		TYPEWRITER_TIME_PER_CHAR * float(text.length()),
		TYPEWRITER_MIN_DURATION,
		TYPEWRITER_MAX_DURATION
	)
	typewriter_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	typewriter_tween.tween_property(dialogue_label, "visible_characters", text.length(), typewriter_duration)

	if typewriter_tween:
		await typewriter_tween.finished
	await anim.animation_finished

	await get_tree().create_timer(duration).timeout

	anim.play("fade_out")
	await anim.animation_finished

	dialogue_label.visible = false
	showing_dialogue = false

extends Control
class_name ControlsUI

@onready var label: Label = $ControlsLabel

func _ready() -> void:
	if label:
		label.text = ""
	hide()

func show_controls(text: String) -> void:
	# Shows the controls hint beneath the main HUD
	if label:
		label.text = text
	show()

func show_controls_timed(text: String, duration: float) -> void:
	if label:
		label.text = text
	show()

	# Create a one-shot timer that hides the controls
	var timer := get_tree().create_timer(duration, false)
	timer.timeout.connect(func():
		hide()
		if label:
			label.text = ""
	)

func hide_controls() -> void:
	hide()
	if label:
		label.text = ""

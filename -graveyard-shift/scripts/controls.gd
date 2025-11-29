extends Control
class_name ControlsUI

@onready var label: Label = $Label

func _ready() -> void:
	if label:
		label.text = ""
	hide()

func show_controls(text: String) -> void:
	# Shows the controls hint beneath the main HUD
	if label:
		label.text = text
	show()

func hide_controls() -> void:
	hide()
	if label:
		label.text = ""

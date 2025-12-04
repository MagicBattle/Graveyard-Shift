extends Control
class_name ObjectiveUI

@onready var box: Control = $ObjectiveBox
@onready var background: TextureRect = $ObjectiveBox/TextureRect
@onready var label: Label = $ObjectiveBox/Label

var current_text: String = ""
var is_completed: bool = false


func _ready() -> void:
	# Start hidden and blank.
	if label:
		label.text = ""
	if box:
		box.visible = false
	hide()


func set_objective(text: String, completed: bool = false) -> void:
	# Set or change the current objective text.
	current_text = text
	is_completed = completed
	_refresh()

	# Make the objective UI box visible
	if box:
		box.visible = true
	show()


func mark_completed() -> void:
	# Mark current objective as completed
	if current_text == "":
		return
	is_completed = true
	_refresh()


func clear_objective() -> void:
	# Remove objective completely and hide UI
	current_text = ""
	is_completed = false
	
	if label:
		label.text = ""
	if box:
		box.visible = false
	
	hide()


func _refresh() -> void:
	# Refresh the Label text using current_text + completion state
	if label == null:
		return
	
	if current_text == "":
		label.text = ""
		return
	
	var prefix := "✔ " if is_completed else "Objective: "
	label.text = prefix + current_text

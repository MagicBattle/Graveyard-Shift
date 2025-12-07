extends Control

# Each row = Codes, Codes2, ... (the things you want to hide/show)
@onready var _rows: Array[Control] = [
	$VBoxContainer/Codes,
	$VBoxContainer/Codes2,
	$VBoxContainer/Codes3,
	$VBoxContainer/Codes4,
	$VBoxContainer/Codes5,
	$VBoxContainer/Codes6,
	$VBoxContainer/Codes7,
]

func _ready() -> void:
	for row in _rows:
		var label: Label = row.get_node("ObjectiveBox/Label")
		label.text = ""
		row.visible = false
	visible = false


func _set_slot(idx: int, text: String) -> void:
	if idx < 0 or idx >= _rows.size():
		return

	var row := _rows[idx]
	var label: Label = row.get_node("ObjectiveBox/Label")
	label.text = text
	row.visible = true
	visible = true


func _clear_slot(idx: int) -> void:
	if idx < 0 or idx >= _rows.size():
		return

	var row := _rows[idx]
	var label: Label = row.get_node("ObjectiveBox/Label")
	label.text = ""
	row.visible = false

	# Hide entire CodesUI if all rows are hidden
	var any_visible := false
	for r in _rows:
		if r.visible:
			any_visible = true
			break
	visible = any_visible


# Slot 0: CEO room code
func show_code(pos: int, code: String) -> void:
	var strpos = str(pos+1)
	_set_slot(pos, "#" + strpos + " " + code)

func clear_code(pos: int) -> void:
	_clear_slot(pos)

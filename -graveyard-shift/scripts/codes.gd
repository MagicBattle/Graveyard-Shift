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
	# hide all code rows at start
	for row in _rows:
		var label: Label = row.get_node("ObjectiveBox/Label")
		label.text = ""
		row.visible = false
	visible = false

	# Re-apply any saved codes from Global (in-memory)
	Global.apply_codes_to_ui()  

# helper to set a row with code
func _set_slot(idx: int, text: String) -> void:
	if idx < 0 or idx >= _rows.size():
		return
	var row := _rows[idx]
	var label: Label = row.get_node("ObjectiveBox/Label")
	label.text = text
	row.visible = true
	visible = true  

# helper to clear a row
func _clear_slot(idx: int) -> void:
	if idx < 0 or idx >= _rows.size():
		return
	var row := _rows[idx]
	var label: Label = row.get_node("ObjectiveBox/Label")
	label.text = ""
	row.visible = false

	# hide entire CodesUI if all rows are hidden
	visible = _rows.any(func(r): return r.visible)

# Slot 0: CEO room code
# called by paper stacks, arcade rewards, etc. to show a code in UI
func show_code(pos: int, code: String) -> void:
	var strpos = str(pos + 1)  
	_set_slot(pos, "#" + strpos + " " + code)

# called to remove a code from UI and Global memory
func clear_code(pos: int) -> void:
	_clear_slot(pos)
	Global.clear_code(pos)  

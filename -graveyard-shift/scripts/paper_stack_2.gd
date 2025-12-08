extends Node3D

@export_range(0, 6) var code_index: int = 2
@export var code_string: String = "2580"

var taken: bool = false

func interact() -> void:
	if taken:
		return
	taken = true

	print("Picked up code slot %d : %s" % [code_index, code_string])

	# Show code on UI if CodesUI exists
	var code_ui: Node = get_tree().current_scene.get_node_or_null("UI/PlayerScreen/CodesUI")
	if code_ui != null and code_ui.has_method("show_code"):
		code_ui.show_code(code_index, code_string)

	# Register with Global autoload so it persists across scenes
	Global.register_found_code(code_index, code_string)

	queue_free()

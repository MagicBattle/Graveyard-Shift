extends Node

const WORLD_SCENE_PATH := "res://scenes/main.tscn"
const ARCADE_SCENE_PATH := "res://2d/scenes/main_menu.tscn"

var return_position: Vector3
var return_rotation_y: float
var has_return_position: bool = false

# in-memory storage for found codes (persist for the running session)
var found_codes: Dictionary = {}

# Register or overwrite a code for a slot index
func register_found_code(idx: int, code: String) -> void:
	found_codes[idx] = code


# Remove a stored code for a slot index
func clear_code(idx: int) -> void:
	if found_codes.has(idx):
		found_codes.erase(idx)


func has_code(idx: int) -> bool:
	return found_codes.has(idx)


func get_code(idx: int) -> String:
	return found_codes.get(idx, "")

# Apply any saved codes to the CodeUI in the current scene (if present)
func apply_codes_to_ui() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	var code_ui := current_scene.get_node_or_null("UI/PlayerScreen/CodesUI")
	if code_ui == null:
		return
	if not code_ui.has_method("show_code"):
		return
	for idx_key in found_codes.keys():
		var idx := int(idx_key)
		var code_text := str(found_codes[idx_key])
		code_ui.show_code(idx, code_text)

# Clear all stored in-memory codes
func clear_all_saved_codes() -> void:
	found_codes.clear()


func store_player_transform(player: Node3D) -> void:
	return_position = player.global_position
	return_rotation_y = player.rotation.y
	has_return_position = true


func go_to_arcade() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(ARCADE_SCENE_PATH)


func return_to_world() -> void:
	print("Returning to world…")
	get_tree().paused = false
	get_tree().change_scene_to_file(WORLD_SCENE_PATH)
	GameManager.force_playing_state_after_return()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

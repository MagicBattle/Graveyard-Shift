extends Area2D

# Path to your 3D world scene
@export var world_scene_path: String = "res://scenes/main.tscn"

# Reward config for this Area2D
@export var reward_code_index: int = 6
@export var reward_code_string: String = "1234"
var _given_code: bool = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Only trigger for the player
	if not body is CharacterBody2D:
		return

	# Register reward code if not already given
	if not _given_code:
		_given_code = true
		Global.register_found_code(reward_code_index, reward_code_string)

		# Update Code UI if present
		var code_ui := get_tree().current_scene.get_node_or_null("UI/PlayerScreen/CodesUI")
		if code_ui != null and code_ui.has_method("show_code"):
			code_ui.show_code(reward_code_index, reward_code_string)
	
	print("Player entered Area2D, returning to 3D world with code index ", reward_code_index)

	# Change scene back to the 3D world
	get_tree().change_scene_to_file(world_scene_path)

	# Make sure the player is in proper 3D mode
	GameManager.force_playing_state_after_return()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

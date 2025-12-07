extends Area3D

@export var dialogue_text: String = "Default dialogue"
@export var dialogue_duration: float = 3.0

@onready var player_screen = $"../../UI/PlayerScreen"

var entered = false

func _on_body_entered(body: Node3D) -> void:
	if body.name == "TestingCharacter" and not entered:
		player_screen.show_dialogue(dialogue_text, dialogue_duration)
		entered = true

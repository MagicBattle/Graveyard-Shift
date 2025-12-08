extends Area3D

@export var dialogue_text: String = "All playrooms finished. But why would a kid be playing something this aggressive?"
@export var dialogue_duration: float = 4.5

@onready var player_screen = $"../../UI/PlayerScreen"

var entered = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node3D) -> void:
	# Only trigger if it's the player, not already triggered, and has code index 6
	if body.name == "TestingCharacter" and not entered and Global.has_code(6):
		player_screen.show_dialogue(dialogue_text, dialogue_duration)
		entered = true

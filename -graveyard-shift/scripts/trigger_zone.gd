extends Area3D

@onready var player_screen = $"../UI/PlayerScreen"


func _on_body_entered(body: Node3D) -> void:
	if body.name == "TestingCharacter":
		print("Player entered trigger zone.")
		player_screen.show_dialogue("Dialogue triggered (Player entered trigger zone.)", 3.0)

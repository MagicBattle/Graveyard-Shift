extends Area3D

@onready var willie = $"../"


func _on_body_entered(body: Node3D) -> void:
	if body.name == "TestingCharacter":
		willie.trigger_jumpscare()
		

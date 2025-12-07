# TutorialExitCheckpoint.gd
extends Area3D

@export var tutorial_room_id: String = "tutorial"

var _activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _activated:
		return
	if not (body is CharacterBody3D):
		return

	# Only trigger after tutorial is officially done
	if not GameManager.is_room_completed(tutorial_room_id):
		# Optional: if you *haven’t* already marked it in door.gd, you can do it here:
		# GameManager.mark_room_completed(tutorial_room_id)
		# GameManager.set_phase(GameManager.Phase.OFFICE)
		pass

	# Store checkpoint OUTSIDE the door,
	# so future deaths respawn here instead of back in tutorial.
	Global.store_player_transform(body)
	_activated = true
	print("Tutorial exit checkpoint stored at: ", Global.return_position)

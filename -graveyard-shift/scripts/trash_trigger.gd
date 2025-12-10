extends Area3D
class_name TrashTrigger

signal paper_scored(body: RigidBody3D)

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	# We only care about the paper ball(s)
	if not (body is RigidBody3D):
		return

	# Check if it's our paper ball, either from desk or from spawn system
	if body.is_in_group("paper_throwable") or body.is_in_group("pickup_throwable"):
		emit_signal("paper_scored", body)
		
		if TutorialManager.has_method("on_trash_scored"):
			TutorialManager.on_trash_scored()

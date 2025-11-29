extends Area3D
class_name TrashTrigger

signal paper_scored(body: RigidBody3D)

func _ready() -> void:
	# Connect the body_entered signal so we can react when something enters
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	# We only care about the paper ball(s)
	if not (body is RigidBody3D):
		print("hello")
		return

	# Check if it's our paper ball, either from desk or from spawn system
	if body.is_in_group("paper_throwable") or body.is_in_group("pickup_throwable"):
		print("Paper ball entered trash can!")
		emit_signal("paper_scored", body)
		# If you want, you can also remove the ball here:
		# body.queue_free()

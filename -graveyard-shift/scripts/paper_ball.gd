extends Area3D

@onready var col := $".."

var prev_pos : Vector3


func _ready() -> void:
	#Using this value as given our map there is no way for it to get close to this point
	#resulting in no potential triggers of if statements when unwanted
	prev_pos = Vector3(-1000, -1000, -1000)

func _on_body_entered(body: Node3D) -> void:
	if body is not RigidBody3D:
		if is_equal_approx(global_position.distance_to(prev_pos), 0.0):
			print("DONE")
		else:
			NoiseManager.emit_signal("noise_emitted", global_position, 8)
	if body is CharacterBody3D:
		#body.add_collision_exception_with(self)
		col.add_collision_exception_with(body)

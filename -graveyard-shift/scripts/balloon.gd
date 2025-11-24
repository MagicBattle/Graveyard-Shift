extends Node3D

@onready var particles = $balloon/BalloonPopParticles

func _pop_balloon():
	$balloon/Cone_001.visible = false
	particles.one_shot = true
	particles.emitting = true
	particles.initial_velocity_min = 5.0
	particles.spread = 180
	particles.direction = Vector3.UP
	
	if particles.one_shot:
		while particles.emitting:
			await get_tree().process_frame
		
	

func _on_pop_trigger_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		await _pop_balloon()
		queue_free()

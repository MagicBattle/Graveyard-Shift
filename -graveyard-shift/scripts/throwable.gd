extends RayCast3D


@export var gravity : float = -9.8

var velocity : Vector3

func launch(dir : Vector3 , speed : float):
	velocity = dir.normalized() * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var launch_position = global_position
	velocity.y += gravity * delta
	
	var cposition = launch_position + velocity * delta
	global_position = launch_position
	target_position = cposition - launch_position
	
	if is_colliding():
		#Play Sound Hitting Please
		queue_free()
		return
		
	global_position = cposition

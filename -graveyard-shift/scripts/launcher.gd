extends Node3D

const PROJECTILE = preload("res://scenes/throwable.tscn")

@export var strength_increment : float = 3.0
@export var max_strength : float = 10.0

const base_speed = 5.0
var timer : float
var speed : float = base_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(speed)
	if Input.is_action_pressed("Throw"):
		if speed < max_strength:
			speed += strength_increment * delta
		if speed > max_strength:
			speed = max_strength
		
	if Input.is_action_just_released("Throw"):
		var projectile = PROJECTILE.instantiate()
		get_tree().current_scene.add_child(projectile)
		
		projectile.global_position = global_position
		
		var dir = -get_parent().get_node("Camera3D").global_transform.basis.z

		projectile.launch(dir , speed)
		
		speed = base_speed

	
		
		
		

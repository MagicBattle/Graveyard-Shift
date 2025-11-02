class_name MainCharacter
extends CharacterBody3D

@onready var pivot = $CameraPivot

@export var mouse_sensitivity := 0.002
@export var movement_speed := 5.0
@export var jump_speed := 4.5
@export var weight : float = 50

var direction := Vector3.ZERO
var rotation_x := 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_x = clamp(rotation_x - event.relative.y * mouse_sensitivity, -1.2, 1.2)
		pivot.rotation.x = rotation_x


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += ProjectSettings.get_setting("physics/3d/default_gravity_vector") * delta * weight

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Vector3.ZERO
	direction += -transform.basis.z * Input.get_action_strength("forward")
	direction += transform.basis.z * Input.get_action_strength("back")
	direction += -transform.basis.x * Input.get_action_strength("left")
	direction += transform.basis.x * Input.get_action_strength("right")
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

	move_and_slide()

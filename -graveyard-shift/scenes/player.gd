extends CharacterBody3D

@export var stamina_max : float = 20
@export var stamina_recharge : float = 1
@export var stamina_deletion_rate : float = 5
@export var stamina_rechrage_timer : float = 2

var crouching : bool
var walking : bool
var fire_once : bool
var stamina_current_level : float
var timer : float 
var resting : bool 

var speed
const WALK_SPEED = 1.0
const DEFAULT_SPEED = 2.5
const SPRINT_SPEED = 4.0
const JUMP_VELOCITY = 1.5
const SENSITIVITY = 0.005


#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.04
var t_bob := 0.0

#fov variables 
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var pitch: float = 0.0 

# Stores the camera's original local position so bobbing can return to it
var original_camera_y: Vector3

@onready var head: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

func _ready() -> void:
	stamina_current_level = stamina_max
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_camera_y = camera.transform.origin 
	pitch = camera.rotation.x

	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		pitch = clamp(pitch - event.relative.y * SENSITIVITY, deg_to_rad(-89.0), deg_to_rad(89.0))
		camera.rotation.x = pitch


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY 
	
	#Stamina And Sprinting
	
	if resting and timer >= stamina_rechrage_timer and stamina_current_level < stamina_max:
		if stamina_current_level > stamina_max:
			stamina_current_level = stamina_max
		stamina_current_level += stamina_recharge * delta
		
		
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not Input.is_action_pressed("sprint") or direction == Vector3.ZERO or crouching or walking:
		resting = true
		speed = DEFAULT_SPEED
		timer += delta
		
	
	if crouching:
		speed = DEFAULT_SPEED / 2
		resting = true
		if not fire_once:
			$CollisionShape3D.shape.height = $CollisionShape3D.shape.height / 2
			fire_once = true
		if Input.is_action_just_pressed("crouch"):
			fire_once = false
			crouching = false
	else:
		speed = DEFAULT_SPEED
		if not fire_once:
			$CollisionShape3D.shape.height = $CollisionShape3D.shape.height * 2
			fire_once = true
		if Input.is_action_just_pressed("crouch"):
			fire_once = false
			crouching = true
	
	if stamina_current_level < 0:
		stamina_current_level = 0	
		
		
	if stamina_current_level > 0:
		if Input.is_action_pressed("sprint") and not direction == Vector3.ZERO and not crouching and not walking:
			timer = 0
			resting = false
			speed = SPRINT_SPEED 
			stamina_current_level -= stamina_deletion_rate * delta
	else:
		speed = DEFAULT_SPEED
		resting = true
		timer += delta
	

	
	var previous_speed = speed
	if Input.is_action_pressed("walking"):
		walking = true
		var current_speed = speed / 2
		speed = current_speed / 2
		resting = true
	else:
		walking = false
		speed = previous_speed

	print(speed)
	print(stamina_current_level)
	
	
	# Movement
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# Head bob with return to original height when stopping
	if velocity.length() > 0.0 and direction != Vector3.ZERO:
		t_bob += delta * velocity.length() * float(is_on_floor())
		# Bob around the saved base height
		camera.transform.origin = original_camera_y + _headbob(t_bob)
	else:
		#return to base height and reset timer
		camera.transform.origin = camera.transform.origin.lerp(original_camera_y, delta * 5.0)
		t_bob = 0.0
	
	#fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE + velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ/ 2) * BOB_AMP
	return pos

extends CharacterBody3D

@export var stamina_max : float = 20
@export var stamina_recharge : float = 1
@export var stamina_deletion_rate : float = 5
@export var stamina_rechrage_timer : float = 2

@onready var stamina_bar = $"../UI/PlayerScreen/StaminaBar"

var crouching : bool
var walking : bool
var stamina_current_level : float
var timer : float
var resting : bool

var speed
const DEFAULT_SPEED = 2.5
const SPRINT_SPEED = 4.0
const JUMP_VELOCITY = 4.2
const SENSITIVITY = 0.005

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.04
var t_bob := 0.0

#fov variables 
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var pitch: float = 0.0 
var original_camera_y: Vector3

@onready var head: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var stand_check: RayCast3D = $RayCast3D

#player size + crouch size
const CAPSULE_RADIUS := 0.35
const STAND_HEIGHT := 1.0
const CROUCH_HEIGHT := 0.5
const CROUCH_SPEED_MULT := 0.5
const WALK_SPEED_MULT := CROUCH_SPEED_MULT
var base_head_y := 0.0

func _ready() -> void:
	stamina_current_level = stamina_max
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_camera_y = camera.transform.origin 
	pitch = camera.rotation.x
	base_head_y = head.position.y
	_set_capsule_height(STAND_HEIGHT)

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
	
	# Stamina And Sprinting
	stamina_bar.value = stamina_current_level
	if resting and timer >= stamina_rechrage_timer and stamina_current_level < stamina_max:
		if stamina_current_level > stamina_max:
			stamina_current_level = stamina_max
		stamina_current_level += stamina_recharge * delta
		
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# toggle crouch using fixed heights + headroom check
	if Input.is_action_just_pressed("crouch"):
		if crouching:
			if _can_stand():
				crouching = false
				_set_capsule_height(STAND_HEIGHT)
				head.position.y = base_head_y
		else:
			crouching = true
			_set_capsule_height(CROUCH_HEIGHT)
			head.position.y = base_head_y - 0.4
	
	walking = Input.is_action_pressed("walking")
	var wants_sprint := Input.is_action_pressed("sprint") and direction != Vector3.ZERO and not crouching and not walking

	if stamina_current_level < 0:
		stamina_current_level = 0	

	if wants_sprint and stamina_current_level > 0:
		timer = 0
		resting = false
		speed = SPRINT_SPEED
		stamina_current_level -= stamina_deletion_rate * delta
	else:
		resting = true
		speed = DEFAULT_SPEED
		timer += delta

	if crouching or walking:
		speed = DEFAULT_SPEED * CROUCH_SPEED_MULT
		resting = true
		
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
		camera.transform.origin = original_camera_y + _headbob(t_bob)
	else:
		camera.transform.origin = camera.transform.origin.lerp(original_camera_y, delta * 5.0)
		t_bob = 0.0
	
	# fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE + velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ/ 2) * BOB_AMP
	return pos

# keeps feet planted while changing capsule height
func _set_capsule_height(h: float) -> void:
	var cap := collider.shape as CapsuleShape3D
	var bottom := _collider_bottom_y(cap)
	cap.radius = CAPSULE_RADIUS
	cap.height = h
	collider.position.y = bottom + _capsule_total(h) * 0.5

# how tall the capsule is including the hemispheres
func _capsule_total(h: float) -> float:
	return h + 2.0 * CAPSULE_RADIUS

# current bottom of the capsule in local space
func _collider_bottom_y(cap: CapsuleShape3D) -> float:
	return collider.position.y - _capsule_total(cap.height) * 0.5

# true = there’s room to stand (ray not hitting anything)
func _can_stand() -> bool:
	if stand_check == null:
		return true
	return not stand_check.is_colliding()

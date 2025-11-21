extends CharacterBody3D

@export var stamina_max : float = 20
@export var stamina_recharge : float = 1
@export var stamina_deletion_rate : float = 5
@export var stamina_rechrage_timer : float = 2
@export var degree_tilt = deg_to_rad(45.0)

@onready var stamina_bar = $"../UI/PlayerScreen/StaminaBar"
@onready var inventory: Inventory = $Inventory

var lean_target := 0.0
var leaning_l : bool = false
var leaning_r : bool = false
var crouching : bool
var walking : bool
var stamina_current_level : float
var timer : float
var resting : bool

var speed
const DEFAULT_SPEED = 2.5
const SPRINT_SPEED = 4.0
const JUMP_VELOCITY = 3
const SENSITIVITY = 0.005

# bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.04
var t_bob := 0.0

# fov variables 
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var pitch: float = 0.0 
var original_camera_y: Vector3

@onready var head: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var stand_check: RayCast3D = $RayCast3D

@export_category("Holding Objects")
@export var throwForce = 2.0
@export var followSpeed = 5.0 
@export var followDistance = 2.5 
@export var maxDistanceFromCamera = 5.0 
@export var dropBelowPlayer = false
@export var groundRay: RayCast3D
@export var strength_throw_increment = 1.0
@export var max_strength_throw = 5.0

@onready var interactRay: RayCast3D = $CameraPivot/Camera3D/InteractRay
var heldObject: RigidBody3D
var throw_sound = preload("res://assets/PSX Horror Audio Pack/SFX/throw.mp3")
var power_sound = preload("res://assets/PSX Horror Audio Pack/SFX/power_throw.mp3")

# player size + crouch size
const CAPSULE_RADIUS := 0.4
const STAND_HEIGHT := 1.7
const CROUCH_HEIGHT := 0.7
const CROUCH_SPEED_MULT := 0.5
const WALK_SPEED_MULT := CROUCH_SPEED_MULT
var base_head_y := 0.0

var PAPER_BALL_ITEM := {
	"type": "throwable",
	"scene": preload("res://scenes/throwable.tscn")  # use real throwable scene here
}


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
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# scroll up → previous slot
			inventory.select_next(-1)
			print("Current slot (scroll up): ", inventory.current_index)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# scroll down → next slot
			inventory.select_next(1)
			print("Current slot (scroll down): ", inventory.current_index)

	# --- Number keys 1–9: jump to specific slot ---
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				inventory.select_index(0)
			KEY_2:
				inventory.select_index(1)
			KEY_3:
				inventory.select_index(2)
			KEY_4:
				inventory.select_index(3)
			KEY_5:
				inventory.select_index(4)
			KEY_6:
				inventory.select_index(5)
			KEY_7:
				inventory.select_index(6)
			KEY_8:
				inventory.select_index(7)
			KEY_9:
				inventory.select_index(8)

		print("Current slot (number key): ", inventory.current_index)

func _physics_process(delta: float) -> void:
	handle_holding_objects(delta) 

	if Input.is_action_just_pressed("lean_left") and not leaning_l:
		lean_target = 1.0
		leaning_l = true
		leaning_r = false
	elif Input.is_action_just_pressed("lean_right") and not leaning_r:
		lean_target = -1.0
		leaning_r = true
		leaning_l = false
	elif Input.is_action_just_pressed("lean_left") and leaning_l:
		lean_target = 0.0
		leaning_l = false
		leaning_r = false
	elif Input.is_action_just_pressed("lean_right") and leaning_r:
		lean_target = 0.0
		leaning_l = false
		leaning_r = false
	
	
	$CameraPivot.rotation.z = lerp($CameraPivot.rotation.z, lean_target * degree_tilt, delta * 5.0)
	
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
	pos.x = sin(time * BOB_FREQ / 2.0) * BOB_AMP
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
	
	
func set_held_object(body: RigidBody3D):
	heldObject = body  


func drop_held_object():
	heldObject = null 
	throwForce = 2.0
	
	
func apply_charge(force : float, delta) -> float:
	return force + strength_throw_increment * delta
		

func throw_held_object(delta):
	var obj = heldObject
	if Input.is_action_pressed("Throw"):
		if throwForce < max_strength_throw and not $SFX_Player.playing:
			$SFX_Player.stream = power_sound
			$SFX_Player.play()
		throwForce = apply_charge(throwForce, delta)
	if Input.is_action_just_released("Throw"):
		$SFX_Player.stream = throw_sound
		$SFX_Player.play()
		if throwForce > max_strength_throw:
			throwForce = max_strength_throw
		print(throwForce)
		drop_held_object()
		obj.apply_central_impulse(-camera.global_transform.basis.z * throwForce * 10.0)


func handle_holding_objects(delta):
	if heldObject != null:
		throw_held_object(delta)
		
	if Input.is_action_just_pressed("interact"):
		print("Hello")
		if heldObject != null:
			drop_held_object()
		elif interactRay != null and interactRay.is_colliding():
			var col = interactRay.get_collider()

			# 1) Check if this is the paper ball (or any throwable pickup)
			if col.is_in_group("pickup_throwable"):
				if inventory.add_item(PAPER_BALL_ITEM):
					# We successfully stored it in a slot → remove it from world
					print("hi")
					col.queue_free()
				else:
					# Inventory full – later you can show "Inventory full" UI
					print("Inventory full, can't pick up paper ball")
				return   # stop here, don't also treat it as heldObject

			# 2) Fallback: old behavior (physically hold object in hand)
			if col is RigidBody3D:
				set_held_object(col)
	
	# if we are not holding anything, stop here so we never touch null
	if heldObject == null:
		return
	
	# make object follow camera
	var targetPos = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -followDistance)) 
	var objectPos = heldObject.global_transform.origin 
	heldObject.linear_velocity = (targetPos - objectPos) * followSpeed 
	
	# too far from camera → drop
	if heldObject.global_position.distance_to(camera.global_position) > maxDistanceFromCamera:
		drop_held_object()
		
	#drop if it is below player and ground ray hits it
	if dropBelowPlayer and groundRay != null and groundRay.is_colliding():
		if groundRay.get_collider() == heldObject:
			drop_held_object()

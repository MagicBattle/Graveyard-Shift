extends CharacterBody3D

@export var stamina_max : float = 20
@export var stamina_recharge : float = 1
@export var stamina_deletion_rate : float = 5
@export var stamina_rechrage_timer : float = 2
@export var degree_tilt = deg_to_rad(45.0)

@onready var stamina_bar = $"../UI/PlayerScreen/StaminaBar"
@onready var throw_bar = $"../UI/PlayerScreen/ThrowBar"
#@onready var$CameraPivot/Viewmodel$CameraPivot/Viewmodel inventory: Inventory = $Inventory
var inventory = InventoryManager
@onready var inventory_ui = $"Inventory/InventoryUI/InventoryBar"
@onready var controls_ui = $"../UI/PlayerScreen/ControlsUI"
@onready var viewmodel = $"CameraPivot/Camera3D/Viewmodel"

var lean_target := 0.0
var leaning_l : bool = false
var leaning_r : bool = false
var crouching : bool
var walking : bool
var stamina_current_level : float
var timer : float
var resting : bool
var tutorial_lock_movement: bool = false  # FOR TUTORIAL

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

var cutscene_active: bool = false
var cutscene_velocity: Vector3 = Vector3.ZERO
var cutscene_timer: float = 0.0
var cutscene_duration: float = 0.0


@onready var head: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var stand_check: RayCast3D = $RayCast3D

@export_category("Holding Objects")
@export var throwForce = 0.5
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
	"scene": preload("res://scenes/paper_throwable.tscn"),  # use real throwable scene here
	"icon_path": "res://icons/paper_ball_icon.png",
	#"scene": preload("res://scenes/throwable.tscn"),  # use real throwable scene here
	"mesh": preload("res://assets/PSX_OFFICE_GLTF/Paper Ball/Paper Ball.glb")
}

var PAPER_STACK_ITEM := {
	"type": "boss_file"
}

# M: flag to block player input when UI like keypad is open
var ui_locked: bool = false
var has_boss_file_flag: bool = false

func _ready() -> void:
	inventory.clear_inventory()
	stamina_current_level = stamina_max
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_camera_y = camera.transform.origin 
	pitch = camera.rotation.x
	base_head_y = head.position.y
	_set_capsule_height(STAND_HEIGHT)
	# 🔹 Sync viewmodel with inventory slot changes
	inventory.current_slot_changed.connect(_on_slot_changed)
	
func has_boss_file() -> bool:
	return has_boss_file_flag


func _on_slot_changed(slot_index: int, _item):
	if viewmodel:
		viewmodel._update_held_item(slot_index)	

# M: called by UI to toggle locking on/off
func set_ui_locked(value: bool) -> void:
	ui_locked = value

func set_tutorial_movement_locked(locked: bool) -> void:
	tutorial_lock_movement = locked

	# If we just locked, stop any current horizontal movement
	if locked:
		velocity.x = 0.0
		velocity.z = 0.0

func _unhandled_input(event: InputEvent) -> void:
	# M: if UI is locking input, ignore everything here
	if ui_locked:
		return

	if event is InputEventMouseMotion:
		# M: only rotate camera when mouse is captured so it doesn't snap when UI shows
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			return
		head.rotate_y(-event.relative.x * SENSITIVITY)
		pitch = clamp(pitch - event.relative.y * SENSITIVITY, deg_to_rad(-89.0), deg_to_rad(89.0))
		camera.rotation.x = pitch
		
		# Report look movement to TutorialManager
		var look_amount:float = abs(event.relative.x) + abs(event.relative.y)
		if look_amount > 0.0:
			TutorialManager.on_player_looked(look_amount)
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# scroll up → previous slot
			inventory.select_next(-1)
			#print("Current slot (scroll up): ", inventory.current_index)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# scroll down → next slot
			inventory.select_next(1)
			#print("Current slot (scroll down): ", inventory.current_index)

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

		#print("Current slot (number key): ", inventory.current_index)

func _physics_process(delta: float) -> void:
	if cutscene_active:
		cutscene_timer += delta

		# apply horizontal cutscene velocity
		velocity.x = cutscene_velocity.x
		velocity.z = cutscene_velocity.z

		# still apply gravity
		if not is_on_floor():
			velocity += get_gravity() * delta

		move_and_slide()

		# stop after duration
		if cutscene_timer >= cutscene_duration:
			cutscene_active = false
			velocity.x = 0.0
			velocity.z = 0.0

		return
	# M: if UI is active, freeze movement
	if ui_locked:
		return

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
		##JUST ADDED FOR SOUND
		NoiseManager.emit_signal("noise_emitted", global_position, 5)
	
	# Stamina And Sprinting
	stamina_bar.value = stamina_current_level
	if resting and timer >= stamina_rechrage_timer and stamina_current_level < stamina_max:
		if stamina_current_level > stamina_max:
			stamina_current_level = stamina_max
		stamina_current_level += stamina_recharge * delta
		
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if tutorial_lock_movement:
		# Ignore movement input while locked, but still allow gravity and camera look
		direction = Vector3.ZERO

	
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
		##JUST ADDED FOR SOUND
		if is_equal_approx(speed, DEFAULT_SPEED * CROUCH_SPEED_MULT) and direction != Vector3.ZERO:
			NoiseManager.emit_signal("noise_emitted", global_position, 1)
		elif is_equal_approx(speed, DEFAULT_SPEED) and direction != Vector3.ZERO:
			NoiseManager.emit_signal("noise_emitted", global_position, 5)
		elif is_equal_approx(speed, SPRINT_SPEED) and direction != Vector3.ZERO:
			NoiseManager.emit_signal("noise_emitted", global_position, 10)
			
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
	_update_pickup_hint()
	move_and_slide()


func begin_cutscene_motion(direction: Vector3, speed: float, duration: float) -> void:
	cutscene_active = true
	cutscene_timer = 0.0
	cutscene_duration = duration
	cutscene_velocity = direction.normalized() * speed


func force_look_at_flat(target: Vector3) -> void:
	# Make the target have the same Y as the head so we don't pitch up/down
	var origin: Vector3 = head.global_transform.origin
	var flat_target := Vector3(target.x, origin.y, target.z)

	# This will rotate the head so its -Z faces flat_target
	head.look_at(flat_target, Vector3.UP)

	# Reset pitch so the camera isn't tilted up/down
	pitch = 0.0
	camera.rotation.x = pitch


var _showing_pickup_hint: bool = false

func _update_pickup_hint() -> void:
	# If we don't have a controls UI, bail
	if controls_ui == null:
		return

	# Optional: don't auto-show hints while tutorial is driving controls
	if TutorialManager.ui_locked_by_tutorial:
		if _showing_pickup_hint:
			controls_ui.hide_controls()
			_showing_pickup_hint = false
		return

	# Raycast must be valid and colliding
	if interactRay != null and interactRay.is_colliding():
		var col := interactRay.get_collider()
		
		if col == null:
			# The ray hit, but the collider is invalid now.
			if _showing_pickup_hint:
				controls_ui.hide_controls()
				_showing_pickup_hint = false
			return
		# Is this a pick-up-able object?
		if col.is_in_group("interactable"):
			if not _showing_pickup_hint:
				controls_ui.show_controls("F: Interact")
				_showing_pickup_hint = true
			return

	# If we got here, we are NOT looking at a pickup
	if _showing_pickup_hint:
		controls_ui.hide_controls()
		_showing_pickup_hint = false


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
	throwForce = 1.0
	
	
func apply_charge(force : float, delta) -> float:
	return force + strength_throw_increment * delta
	
	
func _get_current_throwable_item():
	var item = inventory.get_current_item()
	if item == null:
		return null
	if not (item is Dictionary):
		return null
	if not item.has("type") or not item.has("scene"):
		return null
	if item["type"] != "throwable":
		return null
	return item


func throw_held_object(delta):
	if Input.is_action_pressed("Throw"):
		if throwForce < max_strength_throw and not $SFX_Player.playing:
			$SFX_Player.stream = power_sound
			$SFX_Player.play()
		throwForce = apply_charge(throwForce, delta)
		#print(throwForce)
		if throw_bar:
			throw_bar.visible = true
			var percentage = (throwForce / max_strength_throw) * 100
			throw_bar.value = percentage

	if Input.is_action_just_released("Throw"):
		$SFX_Player.stream = throw_sound
		$SFX_Player.play()

		if throwForce > max_strength_throw:
			throwForce = max_strength_throw

		var obj: RigidBody3D = heldObject
		var forward := -camera.global_transform.basis.z

		# If we’re not holding anything, try inventory instead
		if obj == null:
			var item = _get_current_throwable_item()
			if item != null:
				var scene: PackedScene = item["scene"]
				obj = scene.instantiate()
				if obj is RigidBody3D:
					obj.global_transform.origin = camera.global_transform.origin + forward * 1.5
					get_tree().current_scene.add_child(obj)
					# consume inventory item
					inventory.remove_current()
				else:
					return	
				
		if obj is RigidBody3D:
			obj.apply_central_impulse(forward * throwForce * 10.0)
		# If it was a held object, clear the reference
		if heldObject == obj:
			drop_held_object()
		# reset charge for next time
		throwForce = 0.5
		
		if throw_bar:
			throw_bar.visible = false
			throw_bar.value = 0
		
		if viewmodel:
			viewmodel.clear_item()
		# Tell tutorial that a throw happened
		TutorialManager.on_paper_ball_thrown()



func _try_interact_with(col: Node) -> bool:
	print("try")
	if col.has_method("interact"):
		col.interact()
		return true
	
	# --- Inventory pickup: paper ball ---
	if col.is_in_group("paper_throwable"):
		if inventory.add_item(PAPER_BALL_ITEM):
			viewmodel._update_held_item(inventory.current_index)
			print("Picked up paper ball into inventory")
			TutorialManager.on_paper_ball_picked()
			col.queue_free()
		else:
			print("Inventory full, can't pick up paper ball")
		return true

	# --- Inventory pickup: boss file (paper stack on YOUR desk) ---
	if col.is_in_group("file_pickup"):
		if inventory.add_item(PAPER_STACK_ITEM):
			viewmodel._update_held_item(inventory.current_index)
			TutorialManager.on_boss_file_picked()
			has_boss_file_flag = true
			col.queue_free()
			print("Picked up boss file (paper stack) into inventory")
		return true

	# --- Place boss file on BOSS's desk (invisible stack becomes visible) ---
	if col.is_in_group("boss_desk") or col.is_in_group("boss_file_target"):
		return _try_place_boss_file_on_boss_desk()

	# Not handled here
	return false

func _try_place_boss_file_on_boss_desk() -> bool:
	# Check current inventory item
	var item = inventory.get_current_item()
	if item == null:
		print("No item selected to place on boss desk.")
		return false

	# Make sure it's the boss file (your PAPER_STACK_ITEM)
	if not item.has("type") or item["type"] != "boss_file":
		print("Current item is not the boss file; cannot place.")
		return false

	# Find the boss desk file target (StaticBody3D under Paper Stack)
	var targets := get_tree().get_nodes_in_group("boss_file_target")
	if targets.is_empty():
		print("No boss_file_target found in scene.")
		return false

	var target_body := targets[0] as Node3D
	if target_body == null:
		return false

	# Its parent is the MeshInstance3D "Paper Stack"
	var parent := target_body.get_parent()
	if parent == null:
		return false

	# Turn on the mesh visibility
	for child in parent.get_children():
		if child is MeshInstance3D:
			child.visible = true
			break

	print("Placed boss file on boss's desk (revealed pre-placed stack).")

	# Remove file from inventory & clear viewmodel
	inventory.remove_current()
	if viewmodel:
		viewmodel.clear_item()
		
	has_boss_file_flag = false

	TutorialManager.on_boss_file_placed()

	return true




func handle_holding_objects(delta):
	if Input.is_action_just_pressed("spawn"):
		_spawn_current_item()
		
	if heldObject != null or not inventory.is_slot_empty(inventory.current_index):
		throw_held_object(delta)
		
	if Input.is_action_just_pressed("Aim"):
		if interactRay != null and interactRay.is_colliding():
			var col = interactRay.get_collider()
			if col is RigidBody3D:
				set_held_object(col)
			
	if Input.is_action_just_pressed("interact"):
		if heldObject != null:
			drop_held_object()
		elif interactRay != null and interactRay.is_colliding():
			var col = interactRay.get_collider()
			if _try_interact_with(col):
				return
			
			# Inventory pickup (paper ball)
			"""if col.is_in_group("paper_throwable"):
				if inventory.add_item(PAPER_BALL_ITEM):
					viewmodel._update_held_item(inventory.current_index)
					print("Picked up paper ball into inventory")
					col.queue_free()
				else:
					print("Inventory full, can't pick up paper ball")
				return   # stop here, don't also treat it as heldObject
			elif col.is_in_group("pickup"):
				if inventory.add_item(PAPER_STACK_ITEM):
					viewmodel._update_held_item(inventory.current_index)
					col.queue_free()
					print(inventory.slots)
				return"""
				
			
			# interact with tv scens
			var target: Node = col

			# move up the parent chain until we find a node with interact()
			while target != null and not target.has_method("interact"):
				target = target.get_parent()

			if target != null and target.has_method("interact"):
				target.interact()
				return
	
	# if we are not holding anything, stop here so we never touch null
	if heldObject == null:
		return
	
	# Make object follow camera while held
	var targetPos = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -followDistance)) 
	var objectPos = heldObject.global_transform.origin 
	heldObject.linear_velocity = (targetPos - objectPos) * followSpeed 
	
	# too far from camera → drop
	if heldObject.global_position.distance_to(camera.global_position) > maxDistanceFromCamera:
		drop_held_object()
		
	# drop if it is below player and ground ray hits it
	if dropBelowPlayer and groundRay != null and groundRay.is_colliding():
		if groundRay.get_collider() == heldObject:
			drop_held_object()
			


func _spawn_current_item():
	var original = inventory.get_current_item()
	if original == null:
		return
		
	var _spawn_item : PackedScene = original["scene"]
	var item = _spawn_item.instantiate()
	var mesh_source : PackedScene = original["mesh"]
	item.set("type", "throwable")
	item.add_to_group("pickup_throwable")
	var offset = Vector3(0, 0.1, 0.5)
	var _pos : Vector3
	if interactRay.is_colliding():
		var col = interactRay.get_collider()
		if col is RayCast3D:
			_pos = interactRay.global_position + -interactRay.global_transform.basis.z * offset
		else:
			var col_point = interactRay.get_collision_point()
			var direction_to_camera = (camera.global_transform.origin - col_point).normalized()
			_pos = col_point + direction_to_camera * 0.2
	else:
		_pos = interactRay.global_position + -interactRay.global_transform.basis.z * offset
	var scales = Vector3(0.2, 0.2, 0.2)
	item.global_position = _pos
	
	var mesh = _get_mesh(mesh_source)

	item.set_mesh_and_collision(mesh, scales)
	get_tree().current_scene.add_child(item)
	
	inventory.remove_current()


func _get_mesh(glb_scene : PackedScene):
	var inst = glb_scene.instantiate()
	
	for collision in inst.get_children():
		if collision is CollisionShape3D:
			collision.disabled = true
		
	return find_mesh(inst)


func find_mesh(node : Node) -> Mesh:
	if node is MeshInstance3D:
		return node.mesh
	for child in node.get_children():
		if child is Node:
			var m = find_mesh(child)
			if not m == null:
				return m
	return null  

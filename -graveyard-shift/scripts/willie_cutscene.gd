extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim: AnimationPlayer = $SteamboatWillyMesh/AnimationPlayer

var _active: bool = false
var _target: Vector3 = Vector3.ZERO
var _speed: float = 1.8

enum Mode { NONE, TO_DOOR, TO_DISTRACTION }
var _mode: Mode = Mode.NONE

func start_tutorial_walk_to(target_pos: Vector3) -> void:
	_mode = Mode.TO_DOOR
	_active = true
	_target = target_pos

	if nav_agent:
		nav_agent.target_position = target_pos

	# 🔹 Start walking animation
	if anim and anim.has_animation("Orc Walk/mixamo_com"):
		anim.play("Orc Walk/mixamo_com")

func stop_tutorial_and_face(target: Vector3) -> void:
	# stop tutorial movement logic
	_active = false
	velocity = Vector3.ZERO
	print("In face")
	# idle animation once he stops at the door
	if anim and anim.has_animation("Idlev2/mixamo_com"):
		anim.play("Idlev2/mixamo_com")

	# rotate to look at target (door marker) on flat ground
	var p := Vector3(target.x, global_position.y, target.z)
	look_at(p, Vector3.UP)


func go_to_distraction(target_pos: Vector3) -> void:
	_mode = Mode.TO_DISTRACTION
	_active = true
	_target = target_pos

	if nav_agent:
		nav_agent.target_position = target_pos

	# Keep walking animation
	if anim and anim.has_animation("Orc Walk/mixamo_com"):
		anim.play("Orc Walk/mixamo_com")


func end_tutorial_and_enable_normal_ai() -> void:
	# Despawn cutscene monster — real AI takes over later
	queue_free()


func _physics_process(delta: float) -> void:
	if not _active:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var moving := false

	if nav_agent:
		var next_pos: Vector3 = nav_agent.get_next_path_position()
		var dir: Vector3 = next_pos - global_position
		dir.y = 0.0

		if dir.length() > 0.1:
			dir = dir.normalized()
			velocity.x = dir.x * _speed
			velocity.z = dir.z * _speed
			moving = true

			look_at(Vector3(next_pos.x, global_position.y, next_pos.z), Vector3.UP)
		else:
			velocity.x = 0.0
			velocity.z = 0.0
			moving = false

			# If done walking to distraction → despawn
			if _mode == Mode.TO_DISTRACTION:
				#monster.animation_player.play("Idlev2/mixamo_com")
				anim.play("Idlev2/mixamo_com")
				queue_free()
				_active = false

	# Apply movement
	move_and_slide()

	# 🔹 Animation update
	if anim:
		if moving:
			anim.play("Orc Walk/mixamo_com")
		else:
			if anim.has_animation("Idlev2/mixamo_com") and anim.current_animation != "Idlev2/mixamo_com":
				anim.play("idle")

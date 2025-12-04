extends CharacterBody3D

enum States {
	ROAMING,
	LOOKING,
	SEEKING,
}

@onready var player = $"../TestingCharacter"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var ear: RayCast3D = $EarCast

const WALK_VELOCITY = 1.0
const RUN_VELOCITY = 2.0
const ROAM_DIST = 5.0

var _has_noise := false
var _noise_pos: Vector3
var _noise_vol: float
var curr_state : States

# ---------- TUTORIAL OVERRIDE ----------
var tutorial_mode: bool = false
var tutorial_target: Vector3
var tutorial_speed: float = 2.0  # tweak

# random roaming
var rand_path : Vector3

func _ready() -> void:
	curr_state = States.SEEKING
	NoiseManager.noise_emitted.connect(_on_noise_emitted)
	rand_path = get_rand_path()


# Called by TutorialManager when we want the monster to walk to CEO door
func start_tutorial_walk_to(target_pos: Vector3) -> void:
	tutorial_mode = true
	tutorial_target = target_pos
	if nav_agent:
		nav_agent.target_position = target_pos
	print("Monster: tutorial walk to door started.")


# Called by TutorialManager when monster goes to the “distracting sound”
func go_to_distraction(target_pos: Vector3) -> void:
	tutorial_mode = true
	tutorial_target = target_pos
	if nav_agent:
		nav_agent.target_position = target_pos
	print("Monster: going to distraction sound.")


# Called by TutorialManager when the scripted sequence is over
func end_tutorial_and_enable_normal_ai() -> void:
	tutorial_mode = false
	# if you later add a state machine, you can force it back to ROAMING here
	# curr_state = States.ROAMING


func _on_noise_emitted(pos: Vector3, volume: float) -> void:
	_noise_pos = pos
	_noise_vol = volume
	_has_noise = true


func _physics_process(delta: float) -> void:
	# ---------- TUTORIAL MOVEMENT OVERRIDE ----------
	if tutorial_mode:
		if nav_agent:
			var next_pos := nav_agent.get_next_path_position()
			var dir := next_pos - global_position
			dir.y = 0.0

			if dir.length() > 0.1:
				dir = dir.normalized()
				velocity.x = dir.x * tutorial_speed
				velocity.z = dir.z * tutorial_speed
				move_and_slide()
			else:
				# reached tutorial target, just stand here until TutorialManager
				# tells us to do something else
				velocity = Vector3.ZERO
				move_and_slide()
		return
	# ---------- NORMAL AI BELOW ----------

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if _has_noise:
		ear.target_position = to_local(_noise_pos)
		ear.clear_exceptions()
		
		var heard := NoiseManager.compute_perceived(_noise_pos, global_position, _noise_vol)
		
		var walls_hit: int = 0
		const MAX_HITS: int = 3
		
		print("Before", heard)
		for i in range(MAX_HITS):
			ear.force_raycast_update()
			if not ear.is_colliding():
				break
			walls_hit += 1
			var col := ear.get_collider()
			if col:
				ear.add_exception(col)
			else:
				break
		
		var damp_by_walls := [1.0, 0.75, 0.5, 0.25]
		var tier: int = clamp(walls_hit, 0, 3)
		print("Walls hit: ", walls_hit)
		heard *= float(damp_by_walls[tier])
		
		if heard > 0.0:
			listen(_noise_pos, heard)

		_has_noise = false
	
	match curr_state:
		States.ROAMING:
			if global_position.distance_to(rand_path) <= 0.5:
				rand_path = get_rand_path()
			set_path(rand_path, WALK_VELOCITY)
		States.LOOKING:
			print("IMPLEMENT")
		States.SEEKING:
			set_path(player.global_position, RUN_VELOCITY)
		
	move_and_slide()


func set_path(target : Vector3, speed : float) -> void:
	velocity = Vector3.ZERO
	nav_agent.set_target_position(target)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)


func get_rand_path() -> Vector3:
	var x = randf_range(global_position.x - ROAM_DIST, global_position.x + ROAM_DIST)
	var z = randf_range(global_position.z - ROAM_DIST, global_position.z + ROAM_DIST)
	return Vector3(x, global_position.y, z)


func listen(location : Vector3, strength :float) -> void:
	if strength > 0.0:
		print("Monster heard something. Volume:", strength, " at ", location)
	else:
		print("No sound heard")
		
		
func trigger_jumpscare():
	get_tree().paused = true 
	get_tree().change_scene_to_file("res://scenes/jumpscare.tscn")

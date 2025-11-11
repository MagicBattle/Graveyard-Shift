##TODO
##1) NEED TO FIGURE OUT A WAY TO CALCULATE THE BOUNDS OF THE MAP SO IN ROAMING
##STATE THE MONSTER DOESN'T TRY TO GO SOMEWHERE OUTSIDE OF THE MAP (THIS MIGHT
##BE ACHIEVEABLE BY USING THE NAVIGATIONREGION3D IN THE MAIN SCENE)
##2) PROPERLY IMPLEMENT LOGIC FOR EACH OF THE STATES
##3) MAKE SURE TO ADD EACH AREA TO USE WHEN CHECKING WHAT TO DO WHEN HEARING A
##SOUND

class_name Monster
extends CharacterBody3D

enum States {
	ROAMING,
	LOOKING,
	SEEKING,
}

@onready var player = $"../TestingCharacter"
@onready var nav_agent = $NavigationAgent3D
@onready var ear: RayCast3D = $EarCast

#Constants used for the monsters movement
const WALK_VELOCITY = 1.0
const RUN_VELOCITY = 4.0
const ROAM_DIST = 5.0

var _has_noise := false
var _noise_pos: Vector3
var _noise_vol: float
var curr_state : States

#variable to hold the path the monster is following in ROAMING State
var rand_path : Vector3



func _ready() -> void:
	curr_state = States.ROAMING
	NoiseManager.noise_emitted.connect(_on_noise_emitted)
	rand_path = get_rand_path()

func _on_noise_emitted(pos: Vector3, volume: float) -> void:
	_noise_pos = pos
	_noise_vol = volume
	_has_noise = true


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Noise logic: perceived noise = base_volume / (1.0 + pow(distance / falloff, 2.0))
	# Sound decreases with distance (sound intensity loss)
	# if there are walls between monster and player, the sound dampens more
	if _has_noise:
		# aim ray to the noise (RayCast3D expects local space)
		ear.target_position = to_local(_noise_pos)
		
		# Clear any old exceptions so the ray can hit everything again.
		ear.clear_exceptions()
		
		# compute perceived volume
		var heard := NoiseManager.compute_perceived(_noise_pos, global_position, _noise_vol)
		
		var walls_hit: int = 0
		const MAX_HITS: int = 3
		
		print("Before", heard)
		for i in range(MAX_HITS):
			
			# force the raycast to update
			ear.force_raycast_update()
			
			# if no collision, path is clear
			if not ear.is_colliding():
				break
			walls_hit += 1
			
			# get the wall that the raycast collided with
			# add it to exception to ignore it for next iterations
			var col := ear.get_collider()
			if col:
				ear.add_exception(col)
			else:
				break
		
		# dampen sound based on walls hit
		# 0 walls: 1.0, 1 wall: 0.75, 2 walls: 0.5, 3 walls: 0.25
		var damp_by_walls := [1.0, 0.75, 0.5, 0.25]
		var tier: int = clamp(walls_hit, 0, 3)
		
		print("Walls hit: ", walls_hit)
		heard *= float(damp_by_walls[tier])
		
		# send to listen to react appropiately based on heard sound
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
	#CAUSES ERROR WITH LOOKATMODIFIER
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
	# FOR TESTING
	if strength > 0.0:
		print("Monster heard something. Volume:", strength, " at ", location)
	else:
		print("No sound heard")

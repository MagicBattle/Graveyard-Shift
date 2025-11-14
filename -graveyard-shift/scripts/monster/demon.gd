##TODO
##1) NEED TO FIGURE OUT A WAY TO CALCULATE THE BOUNDS OF THE MAP SO IN ROAMING
##STATE THE MONSTER DOESN'T TRY TO GO SOMEWHERE OUTSIDE OF THE MAP (THIS MIGHT
##BE ACHIEVEABLE BY USING THE NAVIGATIONREGION3D IN THE MAIN SCENE)
##2) PROPERLY IMPLEMENT LOGIC FOR EACH OF THE STATES
##3) MAKE SURE TO ADD EACH AREA TO USE WHEN CHECKING WHAT TO DO WHEN HEARING A
##SOUND

#Currently 4 states the monster can be in roaming, looking, seeking, chasing.
#Roaming is walking in random directions. Looking is moving towards and area
#where a sound was heard. Seeking is looking in an area where a loud enough
#sound was heard. Chasing is the monster directly chasing after the player.

class_name Monster
extends CharacterBody3D


@onready var player = $"../TestingCharacter"
@onready var nav_agent = $NavigationAgent3D
@onready var ear: RayCast3D = $EarCast
@onready var monster_state = $"../Monster_State_Manager"

#Variables to distinguish what is a loud sound from a quiet sound
const sound_limit : float = 1.0
#const high_sound : float = 1.0
#const low_sound : float = 0.0

#Variables to distinguish the areas a sound could be
const curious : float = 9.0
const inspective : float = 5.0
const angry : float = 3.0

var _has_noise := false
var _noise_pos: Vector3
var _noise_vol: float

var states : Dictionary = {}
var curr_state : Monster_State

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	
	NoiseManager.noise_emitted.connect(_on_noise_emitted)
	
	for child in monster_state.get_children():
		if child is Monster_State:
			states[child.name.to_lower()] = child
	
	curr_state = states["chasing"]
	
	#curr_state.set_up(player.global_position)
	#print(states)


func _on_noise_emitted(pos: Vector3, volume: float) -> void:
	_noise_pos = pos
	_noise_vol = volume
	_has_noise = true


func _physics_process(delta: float) -> void:
	#print(curr_state)
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if _has_noise:
		sound_logic()
	
	curr_state.action(delta)
	
	move_and_slide()


func listen(location : Vector3, strength :float) -> void:
	# FOR TESTING
	if strength > 0.0:
		print("Monster heard something. Volume:", strength, " at ", location)
	else:
		print("No sound heard")
	
	var monster_xz = Vector2(global_position.x, global_position.z)
	var loc_xz = Vector2(location.x, location.z)
	var dis = monster_xz.distance_to(loc_xz)
	
	if dis > curious:
		#Outside of curious range
		pass
	elif dis <= curious and dis > inspective:
		#In curious range
		if strength <= sound_limit:
			#Roam
			curr_state = states["roaming"]
		else:
			#Looking
			curr_state = states["looking"]
			curr_state.set_up(location)
	elif dis <= inspective and dis > angry:
		#In inspective range
		if strength <= sound_limit:
			#looking towards area
			curr_state = states["looking"]
			curr_state.set_up(location)
		else:
			#searching
			curr_state = states["searching"]
			curr_state.set_up(location)
	else:
		#In angry range
		if strength <= sound_limit:
			#searching
			curr_state = states["searching"]
			curr_state.set_up(location)
		else:
			#chasing
			curr_state = states["chasing"]


func change_state(state_name : String):
	curr_state = states[state_name]


# Noise logic: perceived noise = base_volume / (1.0 + pow(distance / falloff, 2.0))
# Sound decreases with distance (sound intensity loss) if there are walls between 
# monster and player, the sound dampens more
func sound_logic() -> void:
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

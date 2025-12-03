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
@onready var animation_player = $SteamboatWillyMesh/AnimationPlayer
@onready var chase_music: AudioStreamPlayer = $ChaseMusic

#Variables to distinguish what is a loud sound from a quiet sound
const high_sound : float = 6.0
const low_sound : float = 2.5
const very_loud_sound : float = 9.0

#Variables to distinguish the areas a sound could be
const curious : float = 9.0
const inspective : float = 5.0
const angry : float = 3.0

var _has_noise := false
var _noise_pos: Vector3
var _noise_vol: float

var states : Dictionary = {}
var curr_state : Monster_State
var state_delay : Timer
var cant_move : bool = false

var rng = RandomNumberGenerator.new()

var tutorial_mode: bool = false
var tutorial_target: Vector3 = Vector3.ZERO
var tutorial_speed: float = 1.8  # tweak to match your door timing

var _saved_state_name: String = ""


func _ready() -> void:
	rng.randomize()

	NoiseManager.noise_emitted.connect(_on_noise_emitted)

	for child in monster_state.get_children():
		if child is Monster_State:
			states[child.name.to_lower()] = child

	curr_state = states["roaming"]

	#curr_state.set_up(player.global_position)
	#print(states)
	
func start_tutorial_walk_to(target_pos: Vector3) -> void:
	# Save which state we were in so we can restore later
	_saved_state_name = ""
	for key in states.keys():
		if states[key] == curr_state:
			_saved_state_name = key
			break

	tutorial_mode = true
	tutorial_target = target_pos

	if nav_agent:
		nav_agent.set_target_position(target_pos)

	print("Monster: tutorial walk to door started at ", target_pos)


func go_to_distraction(target_pos: Vector3) -> void:
	tutorial_mode = true
	tutorial_target = target_pos

	if nav_agent:
		nav_agent.set_target_position(target_pos)

	print("Monster: going to distraction at ", target_pos)


func end_tutorial_and_enable_normal_ai() -> void:
	tutorial_mode = false
	_has_noise = false  # clear any stale sound
	
	# Reset navigation agent
	if nav_agent:
		nav_agent.target_position = global_position  # Stop moving
		nav_agent.set_target_position(global_position)
	
	# Force return to roaming state
	if states.has("roaming"):
		curr_state = states["roaming"]
		# Reset the roaming state
		curr_state.path = curr_state.get_rand_path()
	
	print("Monster: tutorial finished, normal AI re-enabled. State: ", curr_state.name)


func _on_noise_emitted(pos: Vector3, volume: float) -> void:
	_noise_pos = pos
	_noise_vol = volume
	_has_noise = true


func _physics_process(delta: float) -> void:
	if cant_move:
		return
	#print(curr_state)

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# --- TUTORIAL OVERRIDE ---
	if tutorial_mode:
		if nav_agent:
			var next_pos: Vector3 = nav_agent.get_next_path_position()
			var dir: Vector3 = next_pos - global_position
			dir.y = 0.0

			if dir.length() > 0.1:
				dir = dir.normalized()
				velocity.x = dir.x * tutorial_speed
				velocity.z = dir.z * tutorial_speed

				# face roughly toward the final tutorial target
				look_at(Vector3(tutorial_target.x, global_position.y, tutorial_target.z), Vector3.UP)
			else:
				# reached current path goal; stop
				velocity.x = 0.0
				velocity.z = 0.0

		move_and_slide()
		return
	# --- END TUTORIAL OVERRIDE ---
	
	#print("Monster AI: tutorial_mode =", tutorial_mode, "state =", curr_state)
	if _has_noise:
		sound_logic()
	
	curr_state.action(delta)
	
	move_and_slide()
	
func _handle_chase_music(old_state: Monster_State, new_state: Monster_State) -> void:
	if old_state == new_state or new_state == null:
		return
	
	if new_state == states.get("chasing"):
		_start_chase_music()
	elif old_state == states.get("chasing"):
		_stop_chase_music()
		

func _start_chase_music() -> void:
	if chase_music == null:
		return
	if chase_music.playing:
		return
	
	chase_music.pitch_scale = rng.randf_range(0.98, 1.02)
	chase_music.play()

func _stop_chase_music() -> void:
	if chase_music and chase_music.playing:
		chase_music.stop()

func listen(location : Vector3, strength :float) -> void:
	# FOR TESTING
	#if strength > 0.0:
		#print("Monster heard something. Volume:", strength, " at ", location)
	#else:
		#print("No sound heard")
	
	#var monster_xz = Vector2(global_position.x, global_position.z)
	#var loc_xz = Vector2(location.x, location.z)
	#var dis = monster_xz.distance_to(loc_xz)
	
	if curr_state == states["roaming"]:
		#In curious range
		if strength > low_sound:
			#Roam
			print("STATE looking")
			change_state("looking")
			curr_state.set_up(location)
	elif curr_state == states["looking"]:
		#In inspective range
		if strength >= low_sound:
			#searching
			print("STATE searching")
			change_state("searching")
			curr_state.set_up(location)
	elif curr_state == states["searching"]:
		#In angry range
		if strength >= high_sound:
			#chasing
			print("STATE storming")
			change_state("storming")
			curr_state.set_up(location)
	elif curr_state == states["storming"]:
		curr_state.sound_heard(strength, location)
		if strength >= high_sound:
			change_state("chasing")


func change_state(state_name : String):
	var old_state: Monster_State = curr_state
	curr_state = states[state_name]
	_handle_chase_music(old_state, curr_state)


func set_up_state(loc : Vector3):
	curr_state.set_up(loc)


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
	
	if heard > 0:
		var walls_hit: int = 0
		const MAX_HITS: int = 3
		
		#print("Before: ", heard)
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
		
		#print("Walls hit: ", walls_hit)
		heard *= float(damp_by_walls[tier])
	
		# send to listen to react appropiately based on heard sound
		if heard > 0.0:
			listen(_noise_pos, heard)
			#print(walls_hit, " ", heard)
		
		#print()
		_has_noise = false


func dont_move():
	cant_move = true

func can_move():
	cant_move = false

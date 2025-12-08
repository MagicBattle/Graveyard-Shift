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
@onready var state_audio: AudioStreamPlayer3D = $StateAudio

#Variables to distinguish what is a loud sound from a quiet sound
const high_sound : float = 4.0
const low_sound : float = 1.5
const very_loud_sound : float = 9.0
const delay : float = 0.25

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
var prev_strength : float

var cant_move : bool = false
var rng = RandomNumberGenerator.new()

var state_sounds := {
		"roaming": [
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (1).mp3"),
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (2).mp3")
		],
		"looking": [
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (3).mp3"),
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (4).mp3")
		],
		"searching": [
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (5).mp3"),
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (6).mp3")
		],
		"storming": [
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (7).mp3"),
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (8).mp3")
		],
		"chasing": [
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (9).mp3"),
				preload("res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (10).mp3")
		]
}

var tutorial_mode: bool = false
var tutorial_target: Vector3 = Vector3.ZERO
var tutorial_speed: float = 1.8
var _saved_state_name: String = ""

func _ready() -> void:
	rng.randomize()
	NoiseManager.noise_emitted.connect(_on_noise_emitted)

	for child in monster_state.get_children():
		if child is Monster_State:
			states[child.name.to_lower()] = child

	curr_state = states["roaming"]

	state_delay = Timer.new()
	state_delay.one_shot = true
	add_child(state_delay)

func start_tutorial_walk_to(target_pos: Vector3) -> void:
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
	_has_noise = false

	if nav_agent:
		nav_agent.target_position = global_position
		nav_agent.set_target_position(global_position)

	if states.has("roaming"):
		_transition_state("roaming")
		curr_state.path = curr_state.get_rand_path()

	print("Monster: tutorial finished, normal AI re-enabled. State: ", curr_state.name)

func _on_noise_emitted(pos: Vector3, volume: float) -> void:
	if GameManager.is_room_completed("tutorial"):
		_noise_pos = pos
		_noise_vol = volume
		_has_noise = true

func _physics_process(delta: float) -> void:
	if cant_move:
		return

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

				look_at(Vector3(tutorial_target.x, global_position.y, tutorial_target.z), Vector3.UP)
			else:
				velocity.x = 0.0
				velocity.z = 0.0

		move_and_slide()
		return
	# --- END TUTORIAL OVERRIDE ---

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

func listen(location : Vector3, strength : float) -> void:
	if curr_state == states["storming"]:
		curr_state.sound_heard(strength, location)

	if state_delay.is_stopped() or (prev_strength + 1.0) <= strength:
		if curr_state == states["roaming"]:
			if strength > low_sound:
				print("STATE looking")
				_transition_state("looking")
				curr_state.set_up(location)
				state_delay.start(delay)
				prev_strength = strength

		elif curr_state == states["looking"]:
			if strength >= low_sound:
				print("STATE searching")
				_transition_state("searching")
				curr_state.set_up(location)
				state_delay.start(delay)
				prev_strength = strength

		elif curr_state == states["searching"]:
			if strength >= low_sound:
				print("STATE storming")
				_transition_state("storming")
				curr_state.set_up(location)
				state_delay.start(delay)
				prev_strength = strength

func change_state(state_name : String):
	_transition_state(state_name)

func _transition_state(state_name: String) -> void:
	if not states.has(state_name):
		return

	var old_state: Monster_State = curr_state
	var new_state: Monster_State = states[state_name]

	if new_state == null:
		return
	if old_state == new_state:
		return

	curr_state = new_state
	_handle_chase_music(old_state, curr_state)
	_play_state_change_sound(state_name)

func _play_state_change_sound(state_name: String) -> void:
	if state_audio == null:
		return

	var sound_options = state_sounds.get(state_name, null)
	if sound_options == null:
		return

	var stream: AudioStream = null
	if sound_options is Array:
		if sound_options.is_empty():
			return

		stream = sound_options[rng.randi_range(0, sound_options.size() - 1)]
	elif sound_options is AudioStream:
		stream = sound_options
	else:
		return

	state_audio.stop()
	state_audio.stream = stream
	state_audio.pitch_scale = rng.randf_range(0.95, 1.05)
	state_audio.play()


func set_up_state(loc : Vector3):
	curr_state.set_up(loc)

func sound_logic() -> void:
	ear.target_position = to_local(_noise_pos)
	ear.clear_exceptions()

	var heard := NoiseManager.compute_perceived(_noise_pos, global_position, _noise_vol)

	if heard > 0:
		var walls_hit := 0
		const MAX_HITS := 3

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
		var tier: int = int(clamp(walls_hit, 0, 3))

		heard *= float(damp_by_walls[tier])

		if heard > 0.0:
			listen(_noise_pos, heard)

	_has_noise = false

func dont_move():
	cant_move = true

func can_move():
	cant_move = false

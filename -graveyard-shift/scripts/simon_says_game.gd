extends Node3D

@onready var green_light := $"Decorations/Cubicles3/Monitor/StaticBody3D/GreenLight"
@onready var red_light := $"Decorations/Cubicles3/Monitor2/StaticBody3D/RedLight"
@onready var yellow_light := $"Decorations/Cubicles3/Monitor3/StaticBody3D/YellowLight"
@onready var blue_light := $"Decorations/Cubicles3/Monitor4/StaticBody3D/BlueLight"
@onready var interact_ray := get_node("/root/World/TestingCharacter/CameraPivot/Camera3D/InteractRay")
@onready var willie := $"../../Willie"
@onready var dialogue := get_node("/root/World/UI/PlayerScreen")
@onready var willie := $"../../../Willie"

# Sounds
const CLICK_SOUND := preload("res://assets/briz_sounds/keyboard-click-327728.wav")
const VICTORY_SOUND := preload("res://assets/briz_sounds/victory-chime-366449.wav")
const DEFEAT_SOUND := preload("res://assets/briz_sounds/lose-sfx-365579.wav")
const ROUND_START_SOUND := preload("res://assets/briz_sounds/game-start-6104.wav")

@onready var audio_player := get_node("/root/World/SimonSays") as AudioStreamPlayer3D


var test_1 : Array 
var test_2 : Array
var test_3 : Array 
var test_4 : Array
var test_5 : Array
var test_6 : Array 
var test_array : Array
var current_list : Array = []

var test_passed : bool = false

var current_test : int = 0

var play_test : bool
var cancel_test : bool
var exited : bool = false
var test_paused : bool = false

var flashing_lights : bool = false

#reward config (index 4)
@export var reward_code_index: int = 4
@export var reward_code_string: String = "1234"
var _given_code: bool = false

func _ready() -> void:
	test_1 = [green_light]
	test_2 = [green_light, red_light]
	test_3 = [green_light, red_light, red_light]
	test_4 = [green_light, red_light, red_light, yellow_light]
	test_5 = [green_light, red_light, red_light, yellow_light, blue_light]
	test_6 = [green_light, red_light, red_light, yellow_light, blue_light, green_light]

	test_array = [test_1, test_2, test_3, test_4, test_5, test_6]
	
func _process(delta: float) -> void:
	_puzzle_interaction()
	
	
	if test_passed and not flashing_lights:
		flashing_lights = true
		_flash_forever_and_ever()
		_victory_flash()

func _flash_light(light : OmniLight3D):
	light.light_energy = 5.0
	await get_tree().create_timer(0.5).timeout
	
		
	light.light_energy = 0.0
	await get_tree().create_timer(0.3).timeout

func _start_test():
	if current_test >= test_array.size():
		return
	
	play_test = true
	test_paused = true
	
	var pattern = test_array[current_test]
	
	for light in pattern:
		await _flash_light(light)
		
	test_paused = false
	play_test = false
	
func _check_list():
	if current_test >= test_array.size():
		return
	var target = test_array[current_test]

	if not current_list.size() == target.size():
		return
	
	if current_list == target:
		test_paused = true
		current_list.clear()
		await get_tree().create_timer(1.0).timeout
		await _flash_all_lights()
		await get_tree().create_timer(0.8).timeout
		current_test += 1
		if current_test < test_array.size():
			await _start_test()
		else:
			test_passed = true
	else:
		_call_monster()
		current_list.clear()
		await get_tree().create_timer(0.8).timeout
		await _start_test()


func _on_simon_says_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		GameManager.set_phase(GameManager.Phase.SIMON_SAYS)
		green_light.light_energy = 5.0
		red_light.light_energy = 0.0
		yellow_light.light_energy = 0.0
		blue_light.light_energy = 0.0

func _activate_computer(col : OmniLight3D):
	if play_test:
		return
		
	test_paused = true
	current_list.append(col)
	col.light_energy = 5.0
	_play_sound(CLICK_SOUND)
	await get_tree().create_timer(0.5).timeout
	col.light_energy = 0.0
	
	test_paused = false
	
	_check_list()

func _puzzle_interaction():
	if Input.is_action_just_pressed("interact"):
		if interact_ray != null and interact_ray.is_colliding():
			var col = interact_ray.get_collider()
			if col == null:
				return
				
			for child in col.get_children():
				if child is OmniLight3D:
					if not test_paused:
						_activate_computer(child)
						break

func _call_monster():
	_play_sound(DEFEAT_SOUND)
	willie.change_state("chasing")
	#Increase Sound at location and play audio

func _on_start_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		green_light.light_energy = 0.0
		red_light.light_energy = 0.0
		yellow_light.light_energy = 0.0
		blue_light.light_energy = 0.0
		_play_sound(ROUND_START_SOUND)
		await get_tree().create_timer(1.0).timeout
		await _start_test()
			
func _flash_all_lights():
	test_paused = true
	green_light.light_energy = 5.0
	red_light.light_energy = 5.0
	yellow_light.light_energy = 5.0
	blue_light.light_energy = 5.0
	await get_tree().create_timer(1.0).timeout
	green_light.light_energy = 0
	red_light.light_energy = 0
	yellow_light.light_energy = 0
	blue_light.light_energy = 0
	await get_tree().create_timer(1.0).timeout
	test_passed = false

func _flash_forever_and_ever():
	while test_passed and not exited:
		await _flash_all_lights()
	
	if exited:
		green_light.light_energy = 0
		red_light.light_energy = 0
		yellow_light.light_energy = 0
		blue_light.light_energy = 0

func _on_simon_says_trigger_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		if test_passed:
			exited = true

func _victory_flash():
	dialogue.show_dialogue("I did it! Though… expecting a kid to remember all that? Good luck.", 2.0)
	GameManager.set_phase(GameManager.Phase.OFFICE)
	GameManager.mark_room_completed("simon_says")
	# award code once
	if not _given_code:
		_given_code = true
		Global.register_found_code(reward_code_index, reward_code_string)
		var code_ui = get_tree().current_scene.get_node_or_null("UI/PlayerScreen/CodesUI")
		if code_ui != null and code_ui.has_method("show_code"):
			code_ui.show_code(reward_code_index, reward_code_string)

	# Play victory sound
	_play_sound(VICTORY_SOUND)

	GameManager.set_phase(GameManager.Phase.OFFICE)
	GameManager.mark_room_completed("simon_says")

	$Decorations/StartLight/OmniLight3D.light_color = Color(0, 1, 0)
	for i in range(4):
		await get_tree().create_timer(0.5).timeout
		$Decorations/StartLight/OmniLight3D.light_energy = 0.0
		await get_tree().create_timer(0.5).timeout
		$Decorations/StartLight/OmniLight3D.light_energy = 5.0

func _play_sound(stream: AudioStream):
	audio_player.stop()
	audio_player.stream = stream
	audio_player.play()

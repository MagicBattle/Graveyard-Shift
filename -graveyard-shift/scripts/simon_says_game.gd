extends Node3D

@onready var green_light := $"Decorations/Cubicles3/Monitor/StaticBody3D/GreenLight"
@onready var red_light := $"Decorations/Cubicles3/Monitor2/StaticBody3D/RedLight"
@onready var yellow_light := $"Decorations/Cubicles3/Monitor3/StaticBody3D/YellowLight"
@onready var blue_light := $"Decorations/Cubicles3/Monitor4/StaticBody3D/BlueLight"
@onready var interact_ray = get_node("/root/World/TestingCharacter/CameraPivot/Camera3D/InteractRay")

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

var flashing_lights : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_1 = [green_light]
	test_2 = [green_light, red_light]
	test_3 = [green_light, red_light, red_light]
	test_4 = [green_light, red_light, red_light, yellow_light]
	test_5 = [green_light, red_light, red_light, yellow_light, blue_light]
	test_6 = [green_light, red_light, red_light, yellow_light, blue_light, green_light]

	test_array = [test_1, test_2, test_3, test_4, test_5, test_6]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_puzzle_interaction()
	_check_list()
	
	if test_passed and not flashing_lights:
		flashing_lights = true
		_flash_forever_and_ever()
		
		

func _flash_light(light : OmniLight3D):
	light.light_energy = 5.0
	await get_tree().create_timer(0.5).timeout
	
	if cancel_test:
		light.light_energy = 0.0
		return
		
	light.light_energy = 0.0
	await get_tree().create_timer(0.3).timeout


func _start_test():
	if current_test >= test_array.size():
		return
	
	play_test = true
	cancel_test = false
	
	var pattern = test_array[current_test]
	
	for light in pattern:
		await _flash_light(light)
		if cancel_test:
			break
	play_test = false
	

func _check_list():
	if current_test >= test_array.size():
		return
	var target = test_array[current_test]

	if not current_list.size() == target.size():
		return
	
	if current_list == target:
		print("Nice")
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
		print("DIE")
		_call_monster()
		current_list.clear()


func _on_simon_says_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		green_light.light_energy = 5.0
		red_light.light_energy = 0.0
		yellow_light.light_energy = 0.0
		blue_light.light_energy = 0.0


func _activate_computer(col : OmniLight3D):
	current_list.append(col)
	col.light_energy = 5.0
	
	await get_tree().create_timer(0.5).timeout
	
	col.light_energy = 0.0
	


func _puzzle_interaction():
	if Input.is_action_just_pressed("interact"):
		if interact_ray != null and interact_ray.is_colliding():
			if play_test:
				cancel_test = true
			var col = interact_ray.get_collider()
			for child in col.get_children():
				if child is OmniLight3D:
					_activate_computer(child)
					break


func _call_monster():
	pass
	#Increase Sound at location and play audio


func _on_start_trigger_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		green_light.light_energy = 0.0
		red_light.light_energy = 0.0
		yellow_light.light_energy = 0.0
		blue_light.light_energy = 0.0
		await _start_test()


func _on_start_trigger_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		if not test_passed:
			_call_monster()
			print("DIE")
			
			
func _flash_all_lights():
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
